{ buildGoModule, pkger }:
buildGoModule rec {
  pname = "piggy";
  version = "latest";

  src = builtins.fetchGit {
    url = "/home/bobo/projects/go/piggy";
    ref = version;
  };

  vendorSha256 = "sha256-HVOyYS6SJK6uQPz0Bt/WoVJXteYEp6/KtLoTNppsinA=";

}
