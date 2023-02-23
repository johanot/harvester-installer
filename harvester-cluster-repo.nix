{ pkgs }:
let
  name = "harvester-cluster-repo";
  version = "1.1.1";
  
  user = "nginx";
  shadowSetup = import ./shadow-setup.nix { inherit pkgs; };
  configFile = pkgs.writeText "nginx.conf" ''
    daemon off;
    user ${user} ${user};
    http {  
       server {  
                listen 80;  
                root /var/www/html;
      }
    }
    events {
        # events context
        worker_connections 768;
        multi_accept on;
    }  
  '';
  mainRepo = pkgs.fetchFromGitHub {
    owner = "harvester";
    repo = "harvester";
    rev = "v${version}";
    hash = "sha256-pNUw0c8Ems8j0eW+Wi/Er6Nmrtl+IqYwsfjTe2iX/ds=";
  };
  webroot = pkgs.runCommandNoCC "${name}-webroot" {} ''
    mkdir -p $out/var/www/html $out/var/log/nginx $out/var/cache/nginx
    cp -r ${mainRepo}/deploy/charts $out/var/www/html
    ln -sf /dev/stdout $out/var/log/nginx/access.log
    ln -sf /dev/stderr $out/var/log/nginx/error.log
  '';
in
{
  inherit name;
  contents = [webroot (shadowSetup { inherit user; uid = 1; })];
  config.EntryPoint = [ "${pkgs.nginx}/bin/nginx" "-c" configFile ];
}
