"@generated by @aspect_rules_js//npm/private:npm_import.bzl for npm package unused@0.2.2"

# buildifier: disable=bzl-visibility
load("@aspect_rules_js//npm/private:npm_package_store_internal.bzl", _npm_package_store = "npm_package_store_internal")

# buildifier: disable=bzl-visibility
load("@aspect_rules_js//npm/private:npm_link_package_store.bzl", _npm_link_package_store = "npm_link_package_store")

# Generated npm_package_store targets for npm package unused@0.2.2
# buildifier: disable=function-docstring
def npm_imported_package_store(name):
    bazel_package = native.package_name()
    root_package = ""
    is_root = bazel_package == root_package
    if not is_root:
        msg = "No store links in bazel package '%s' for npm package npm package unused@0.2.2. This is neither the root package nor a link package of this package." % bazel_package
        fail(msg)
    if not name.endswith("/unused"):
        msg = "name must end with one of '/unused' when linking the store in package 'unused'; recommended value is 'node_modules/unused'"
        fail(msg)
    link_root_name = name[:-len("/unused")]

    deps = {
        ":.aspect_rules_js/{}/esprima@1.0.0/pkg".format(link_root_name): "esprima",
        ":.aspect_rules_js/{}/minimist@0.0.10/pkg".format(link_root_name): "minimist",
        ":.aspect_rules_js/{}/optimist@0.6.0/pkg".format(link_root_name): "optimist",
        ":.aspect_rules_js/{}/unused@0.2.2/pkg".format(link_root_name): "unused",
        ":.aspect_rules_js/{}/wordwrap@0.0.3/pkg".format(link_root_name): "wordwrap",
    }
    ref_deps = {
        ":.aspect_rules_js/{}/esprima@1.0.0/ref".format(link_root_name): "esprima",
        ":.aspect_rules_js/{}/optimist@0.6.0/ref".format(link_root_name): "optimist",
    }

    store_target_name = ".aspect_rules_js/{}/unused@0.2.2".format(link_root_name)

    # reference target used to avoid circular deps
    _npm_package_store(
        name = "{}/ref".format(store_target_name),
        package = "unused",
        version = "0.2.2",
        exclude_package_contents = [],
        dev = True,
        tags = ["manual"],
    )

    # post-lifecycle target with reference deps for use in terminal target with transitive closure
    _npm_package_store(
        name = "{}/pkg".format(store_target_name),
        src = "{}/pkg_lc".format(store_target_name) if False else "@@_main~npm~npm__unused__0.2.2//:pkg",
        package = "unused",
        version = "0.2.2",
        exclude_package_contents = [],
        dev = True,
        deps = ref_deps,
        tags = ["manual"],
    )

    # package store target with transitive closure of all npm package dependencies
    _npm_package_store(
        name = store_target_name,
        src = None if True else "@@_main~npm~npm__unused__0.2.2//:pkg",
        package = "unused",
        version = "0.2.2",
        exclude_package_contents = [],
        dev = True,
        deps = deps,
        visibility = ["//visibility:public"],
        tags = ["manual"],
    )

    # filegroup target that provides a single file which is
    # package directory for use in $(execpath) and $(rootpath)
    native.filegroup(
        name = "{}/dir".format(store_target_name),
        srcs = [":{}".format(store_target_name)],
        output_group = "package_directory",
        visibility = ["//visibility:public"],
        tags = ["manual"],
    )

# Generated npm_package_store and npm_link_package_store targets for npm package unused@0.2.2
# buildifier: disable=function-docstring
def npm_link_imported_package_store(name):
    bazel_package = native.package_name()
    link_packages = {
        "npm/private/test": ["unused"],
    }
    if bazel_package in link_packages:
        link_aliases = link_packages[bazel_package]
    else:
        link_aliases = ["unused"]

    link_alias = None
    for _link_alias in link_aliases:
        if name.endswith("/{}".format(_link_alias)):
            # longest match wins
            if not link_alias or len(_link_alias) > len(link_alias):
                link_alias = _link_alias
    if not link_alias:
        msg = "name must end with one of '/{{ {link_aliases_comma_separated} }}' when called from package 'unused'; recommended value(s) are 'node_modules/{{ {link_aliases_comma_separated} }}'".format(link_aliases_comma_separated = ", ".join(link_aliases))
        fail(msg)

    link_root_name = name[:-len("/{}".format(link_alias))]
    store_target_name = ".aspect_rules_js/{}/unused@0.2.2".format(link_root_name)

    # terminal package store target to link
    _npm_link_package_store(
        name = name,
        package = link_alias,
        src = "//:{}".format(store_target_name),
        visibility = ["//visibility:private"],
        tags = ["manual"],
    )

    # filegroup target that provides a single file which is
    # package directory for use in $(execpath) and $(rootpath)
    native.filegroup(
        name = "{}/dir".format(name),
        srcs = [":{}".format(name)],
        output_group = "package_directory",
        visibility = ["//visibility:private"],
        tags = ["manual"],
    )

    return [":{}".format(name)] if False else []

# Generated npm_package_store and npm_link_package_store targets for npm package unused@0.2.2
# buildifier: disable=function-docstring
def npm_link_imported_package(
        name = "node_modules",
        link = None,
        fail_if_no_link = True):
    bazel_package = native.package_name()
    root_package = ""
    link_packages = {
        "npm/private/test": ["unused"],
    }

    if link_packages and link != None:
        fail("link attribute cannot be specified when link_packages are set")

    is_link = (link == True) or (link == None and bazel_package in link_packages)
    is_root = bazel_package == root_package

    if fail_if_no_link and not is_root and not link:
        msg = "Nothing to link in bazel package '%s' for npm package npm package unused@0.2.2. This is neither the root package nor a link package of this package." % bazel_package
        fail(msg)

    link_targets = []
    scoped_targets = {}

    if is_link:
        link_aliases = []
        if bazel_package in link_packages:
            link_aliases = link_packages[bazel_package]
        if not link_aliases:
            link_aliases = ["unused"]
        for link_alias in link_aliases:
            link_target_name = "{}/{}".format(name, link_alias)
            npm_link_imported_package_store(name = link_target_name)
            if False:
                link_targets.append(":{}".format(link_target_name))
                link_scope = link_alias[:link_alias.find("/", 1)] if link_alias[0] == "@" else None
                if link_scope:
                    if link_scope not in scoped_targets:
                        scoped_targets[link_scope] = []
                    scoped_targets[link_scope].append(link_target_name)

    if is_root:
        npm_imported_package_store("{}/unused".format(name))

    return (link_targets, scoped_targets)
