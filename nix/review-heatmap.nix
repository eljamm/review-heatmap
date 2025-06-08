{
  lib,
  buildAnkiAddon,
  python3Packages,
  esbuild,
  gitMinimal,
  nodejs,
  aab,
}:

let
  pname = "review-heatmap";
  version = "1.0.1";

  src = ../.;

  review-heatmap = python3Packages.buildPythonApplication {
    inherit pname version src;
    format = "other";

    build-system = with python3Packages; [
      pyqt6
      aab
    ];

    nativeBuildInputs = [
      esbuild
      gitMinimal
      nodejs
    ];

    buildPhase = ''
      runHook preBuild

      # work around missing files
      if [[ ! -d resources/icons/optional ]]; then
        mkdir resources/icons/optional
        for file in patreon thanks twitter youtube; do
          cp resources/icons/email.svg resources/icons/optional/$file.svg
        done
      fi

      aab build

      # build anki-review-heatmap.js
      npm run build

      runHook postBuild
    '';

    installPhase = ''
      runHook preInstall

      mkdir $out
      cp -R build/* $out

      runHook postInstall
    '';
  };
in

buildAnkiAddon (finalAttrs: {
  inherit pname version;
  src = review-heatmap;

  sourceRoot = "${finalAttrs.src.name}/dist/src/review_heatmap";

  meta = {
    description = "Anki add-on to help you keep track of your review activity";
    homepage = "https://github.com/glutanimate/review-heatmap";
    changelog = "https://github.com/glutanimate/review-heatmap/blob/v${finalAttrs.version}/CHANGELOG.md";
    license = lib.licenses.agpl3Only;
    maintainers = with lib.maintainers; [ eljamm ];
  };
})
