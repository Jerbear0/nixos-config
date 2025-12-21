{ config, pkgs, ... }:  
  
{  
  programs.git = {  
    enable = true;  
  
    settings = {  
      user = {  
        name  = "Jeremy";  
        email = "albertjeremy3@gmail.com";  
      };  
  
      init = {  
        defaultBranch = "main";  
      };  
  
      pull = {  
        rebase = false;  
      };  
  
      core = {  
        editor = "nvim";  
      };  
  
      alias = {  
        st = "status";  
        co = "checkout";  
        br = "branch";  
        ci = "commit";  
        lg = "log --oneline --graph --decorate";  
      };  
    };  
  };  
}  
