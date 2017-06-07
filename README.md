# Stackalone

This small program will take a stack-built Haskell project, and puts all
dependencies right next to it, so it can be built from source without requiring
an external repo. Useful for releasing binary files independent of whether e.g.
Hackage or Github are down.

## Usage

Copy `Stackalone.hs` into your Stack project folder and run it. It will do the
downloading and unpacking of all dependencies, and print what you have to add to
your `packages` section in your `stack.yaml` so the packages are discoverable.
