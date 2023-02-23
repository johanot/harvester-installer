{ pkgs }:
let
lib = pkgs.lib;
platformShadowSetup = { user, uid, gid ? uid }: platformShadowSetup' {
    "${user}" = {
      inherit uid gid;
    };
  };
  platformShadowSetup' = users:
  let
    ul = lib.mapAttrsToList (name: v: { inherit name; } // v) users;
    lines = f: lib.concatMapStringsSep "\n" f ul;
  in
  pkgs.buildEnv {
    name = "platform-shadow";
    paths = [
      (
      pkgs.writeTextDir "etc/shadow" (''
        root:!x:::::::
      '' + (lines (user: "${user.name}:!:::::::")))
      )
      (
      pkgs.writeTextDir "etc/passwd" (''
        root:x:0:0::/root:${pkgs.runtimeShell}
      '' + (lines (user: with user; "${name}:x:${toString uid}:${toString gid}::/home/${name}:")))
      )
      (
      pkgs.writeTextDir "etc/group" (''
        root:x:0:
      '' + (lines (user: with user; "${name}:x:${toString gid}:")))
      )
      (
      pkgs.writeTextDir "etc/gshadow" (''
        root:x::
      '' + (lines (user: with user; "${name}:x::")))
      )
    ];
  };
in
  platformShadowSetup
