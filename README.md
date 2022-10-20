# Plutus Starting Template

## Example setup

1. Clone [plutus-apps](https://github.com/input-output-hk/plutus-apps/) repository and this repository.
2. Enter cloned `plutus-apps` repository and checkout the tag corresponding to that mentioned in this repository's [`cabal.project`](./cabal.project) file. 
3. Run `nix-shell` (make sure you have setup `nix` properly, as outlined [here](https://github.com/input-output-hk/plutus/blob/master/README.adoc#iohk-binary-cache)).
4. Inside `nix` shell, enter the directory for this repository and execute:
    ```bash
    cabal configure -f defer-plugin-errors  # See https://cardano.stackexchange.com/questions/459/haskell-ide-inlinable-error-help/6554#6554
    cabal update
    cabal build
    ```
5. In a new shell (not inside `nix-shell`), open this directory inside your editor (say `neovim`). When you open, say [PDR.Validator.hs](./examples/src/PDR/Validator.hs), your HLS will take some time to get ready and then it should work.
6. Back in shell inside `nix`, can run `cabal exec generate-PDR-files` to generate relevant files for `PDR` contract which is an example contract illustrating how to use custom datum & custom redeemer in a parameterized contract.

## How to update

- [cabal.project](./cabal.project) is mostly copy-paste of corresponding file from [plutus-apps](https://github.com/input-output-hk/plutus-apps/) repository for the corresponding tag, I have clearly mentioned my additions and their rational in this file. To update this template, you would need to update this file and perhaps other example files if their is any breaking change.

## Credits

- [plutus-starter](https://github.com/input-output-hk/plutus-starter/).
