{
  fetchFromGitHub,
  godot_4_4,
  jdk,
  lib,
  stdenv
}: godot_4_4.overrideAttrs(oldAttrs: rec {
  pname = "godot-kotlin-jvm";
  version = "0.13.1-4.4.1";

  src = oldAttrs.src;

  kotlinModuleSrc = fetchFromGitHub {
    owner = "utopia-rise";
    repo = pname;
    tag = version;
    hash = "sha256-vtxwk7Wba3FWa1040oqnNgcu7UyzoZMRhNu26fAK6rE=";
  };

  postUnpack = oldAttrs.postUnpack or "" + ''
    mkdir -p $sourceRoot/modules/kotlin_jvm/
    cp -r $kotlinModuleSrc/* $sourceRoot/modules/kotlin_jvm/
    chmod -R +w $sourceRoot/
  '';

  preBuild = oldAttrs.preBuild or "" + ''
    export JAVA_HOME=${jdk}
  '';

  postInstall = oldAttrs.postInstall or "" + ''
    # The kotlin-jvm build creates a binary with the JVM version suffix
    # We need to create the expected symlinks to this versioned binary
    jvm_binary=$(find "$out"/libexec -name "*.jvm.*" -type f | head -n1)

    if [[ -n "$jvm_binary" ]]; then
      cd "$out"/bin
      rm -f godot*

      jvm_basename=$(basename "$jvm_binary")
      ln -sf "../libexec/$jvm_basename" godot4.4
      ln -sf godot4.4 godot4
      ln -sf godot4 godot

      cd -
    fi
  '';
})
