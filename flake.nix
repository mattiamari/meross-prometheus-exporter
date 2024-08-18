{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=a0d6390cb3e82062a35d0288979c45756e481f60";
  };

  outputs = { self, nixpkgs }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs {inherit system;};

      python = (pkgs.python3.withPackages (python-pkgs: [
        python-pkgs.setuptools
        python-pkgs.meross-iot
        python-pkgs.prometheus-client
      ]));

      startScript = pkgs.writeShellScript "meross-prometheus-exporter-start" ''
        ${python}/bin/python main.py
      '';
    in
    {
      packages.${system}.default = pkgs.stdenv.mkDerivation (finalAttrs: {
        pname = "meross-prometheus-exporter";
        version = "1.0.2";

        src = ./src;
        
        installPhase = ''
          mkdir -p $out
          cp -r ./ $out/
          install -m 0755 ${startScript} $out/start
        '';
      });

      devShells.${system}.default = pkgs.mkShell {
        buildInputs = [
          python
        ];
      };
    };
}
