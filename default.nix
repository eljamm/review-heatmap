{
  sources ? import ./nix/npins,
  nixpkgs ? sources.nixpkgs,
  pkgs ? import nixpkgs {
    config = { };
    overlays = [ ];
  },
  lib ? import "${sources.nixpkgs}/lib",
}:
lib.makeScope pkgs.newScope (
  self:
  let
    callPackage = self.newScope {
      inherit (pkgs.anki-utils)
        buildAnkiAddon
        buildAnkiAddonsDir
        ;
    };
    customPython = pkgs.python3.withPackages (
      ps: with ps; [
        jsonschema
        whichcraft
        pyqt6
      ]
    );
  in
  {
    aab = pkgs.python3Packages.callPackage ./nix/aab.nix { };
    review-heatmap = callPackage ./nix/review-heatmap.nix { };

    # Anki with the review-heatmap addon pre-installed. Test with:
    # $ nix-build -A anki && ./result/bin/anki
    anki = pkgs.anki.withAddons [
      self.review-heatmap
    ];

    # dev shell
    shell = pkgs.mkShellNoCC {
      packages = with pkgs; [
        customPython
        esbuild
        nodejs
        self.aab
        self.anki
      ];
      env.NPINS_DIRECTORY = "./nix/npins";
    };
  }
)
