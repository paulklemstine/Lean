# Computational Evidence: Finite Boolean Stages

## Small-case calculations

The stage of index `n` consists of `n+1` Boolean coordinates, so its cardinality is `2^(n+1)`.

| stage `n` | coordinates | cardinality |
|---:|---:|---:|
| 0 | 1 | 2 |
| 1 | 2 | 4 |
| 2 | 3 | 8 |
| 3 | 4 | 16 |
| 4 | 5 | 32 |

For a sequence beginning `(1,0,1,1,0,...)`, restriction gives `(1)`, `(1,0)`, `(1,0,1)`, and `(1,0,1,1)` at stages zero through three. Deleting the final coordinate of each nonzero stage gives the preceding restriction.

## Sequence comparison

The finite-stage cardinalities are the powers of two `2, 4, 8, 16, 32, ...`, the standard binary-growth sequence (OEIS A000079, shifted to begin at exponent one). This comparison concerns only stage sizes and is not used to infer the inverse-limit theorem.

## Counterexample hunt

Two nearby universal claims fail:

1. Nontrivial stages do not force a nontrivial inverse limit: zero bonding maps on nontrivial groups force every coherent coordinate to vanish.
2. Integer multiplication towers can collapse: coherence under repeated multiplication by `2` makes each coordinate divisible by arbitrarily large powers of `2`, hence zero.

The coordinate-deletion tower avoids both failures because every finite vector extends to an infinite sequence, for example by appending zeros.

## Structural table

| bonding rule | finite stages nontrivial? | projection behavior | limit behavior |
|---|---|---|---|
| delete last Boolean coordinate | yes | surjective | countable Boolean product |
| identity | yes | bijective | diagonal copy of one stage |
| zero map | yes | generally not surjective | trivial |
| multiply integers by `2` | yes | not surjective | trivial |

These calculations motivate the decisive hypotheses—coherence and extendability—while the accompanying theorem establishes the result for every stage.
