"Tests that tool runfiles resolve in exec config, not target config, under a platform transition."

load("@bazel_skylib//lib:unittest.bzl", "analysistest", "asserts")

# A minimal rule that produces an executable with a generated data file in its
# runfiles. The generated file lives in a config-specific output directory,
# so we can detect which configuration resolved it.
def _fake_tool_impl(ctx):
    executable = ctx.actions.declare_file(ctx.label.name + ".sh")
    ctx.actions.write(executable, "#!/bin/bash\necho hello\n", is_executable = True)
    data = ctx.actions.declare_file(ctx.label.name + "_data.txt")
    ctx.actions.write(data, "data\n")
    runfiles = ctx.runfiles(files = [data])
    return [DefaultInfo(
        executable = executable,
        runfiles = runfiles,
    )]

_fake_tool = rule(
    implementation = _fake_tool_impl,
    executable = True,
)

# A rule that resolves the same tool in both exec config and target config,
# exposing both file sets via OutputGroupInfo so an analysis test can compare.
def _dual_config_runfiles_impl(ctx):
    exec_runfiles = ctx.attr.tool_exec[DefaultInfo].default_runfiles
    target_runfiles = ctx.attr.tool_target[DefaultInfo].default_runfiles
    exec_files = exec_runfiles.files if exec_runfiles else depset()
    target_files = target_runfiles.files if target_runfiles else depset()
    return [
        DefaultInfo(),
        OutputGroupInfo(
            exec_runfiles = exec_files,
            target_runfiles = target_files,
        ),
    ]

_dual_config_runfiles = rule(
    implementation = _dual_config_runfiles_impl,
    attrs = {
        "tool_exec": attr.label(cfg = "exec", mandatory = True),
        "tool_target": attr.label(mandatory = True),
    },
)

# The analysis test: under a platform transition, exec-config runfiles must
# differ from target-config runfiles. This is exactly the invariant that the
# _exec_tool_runfiles rule in js_run_binary.bzl upholds: it uses cfg = "exec"
# so that hoisted node_modules come from the host platform, not the
# (potentially cross-compiled) target platform.
#
# Without cfg = "exec" (the old code), both would resolve identically in
# target config, causing native addon loading failures when host != target.
def _exec_runfiles_differ_from_target_impl(ctx):
    env = analysistest.begin(ctx)
    target = analysistest.target_under_test(env)

    exec_files = target[OutputGroupInfo].exec_runfiles.to_list()
    target_files = target[OutputGroupInfo].target_runfiles.to_list()

    asserts.true(
        env,
        len(exec_files) > 0,
        "Expected at least one runfile from exec config",
    )
    asserts.true(
        env,
        len(target_files) > 0,
        "Expected at least one runfile from target config",
    )

    exec_roots = sorted([f.root.path for f in exec_files])
    target_roots = sorted([f.root.path for f in target_files])

    asserts.false(
        env,
        exec_roots == target_roots,
        "exec-config runfiles should resolve in a different output root than " +
        "target-config runfiles under a platform transition, but both resolved " +
        "to: %s" % exec_roots,
    )

    return analysistest.end(env)

_FAKE_PLATFORM = str(Label("//js/private/test/exec_tool_runfiles:fake_cross_platform"))

_exec_runfiles_differ_from_target_test = analysistest.make(
    _exec_runfiles_differ_from_target_impl,
    config_settings = {
        "//command_line_option:platforms": _FAKE_PLATFORM,
    },
)

def exec_tool_runfiles_test_suite(name):
    """Test suite proving that cfg='exec' resolves tool runfiles in exec config.

    Args:
        name: Name for the test_suite target.
    """

    # A platform distinct from the host, so target config != exec config.
    native.constraint_setting(
        name = "fake_cpu_setting",
    )
    native.constraint_value(
        name = "fake_cpu_value",
        constraint_setting = ":fake_cpu_setting",
    )
    native.platform(
        name = "fake_cross_platform",
        constraint_values = [":fake_cpu_value"],
    )

    # A tool with generated outputs so its runfiles include at least one
    # config-dependent file (source files have no config-specific root).
    _fake_tool(
        name = "simple_tool",
        tags = ["manual"],
    )

    # Target under test: resolves the same tool in exec and target configs.
    _dual_config_runfiles(
        name = "dual_runfiles_subject",
        tool_exec = ":simple_tool",
        tool_target = ":simple_tool",
        tags = ["manual"],
    )

    _exec_runfiles_differ_from_target_test(
        name = "exec_runfiles_differ_from_target_test",
        target_under_test = ":dual_runfiles_subject",
    )

    native.test_suite(
        name = name,
        tests = [
            ":exec_runfiles_differ_from_target_test",
        ],
    )
