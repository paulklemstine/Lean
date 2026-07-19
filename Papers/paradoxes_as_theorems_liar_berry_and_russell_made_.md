# Computational Evidence

## Small-case calculations

The finite semantics uses the support pairs `(positive, negative)`:

| Sentence | Value | Designated | Negation value | Glut |
|---|---:|---:|---:|---:|
| Liar | `(true, true)` | yes | `(true, true)` | yes |
| Russell | `(true, true)` | yes | `(true, true)` | yes |
| Berry | `(true, true)` | yes | `(true, true)` | yes |
| ordinary truth | `(true, false)` | yes | `(false, true)` | no |
| false witness | `(false, true)` | no | `(true, false)` | no |
| gap witness | `(false, false)` | no | `(false, false)` | no |
| soundness certificate | `(true, true)` | yes | `(true, true)` | yes |

Exhausting the four support pairs confirms that negation swaps the bits and is involutive. Its fixed points are exactly `(true, true)` and `(false, false)`; only the first is designated.

## OEIS search results

No integer sequence drives the conjecture, so an OEIS search is not applicable. The finite evidence concerns a four-element truth algebra and a seven-element sentence language rather than an enumerative sequence.

## Counterexample hunt

The universal classical claim was tested structurally rather than numerically: a complement fixed point `xᶜ = x` forces both `x = ⊥` and `x = ⊤`, hence collapse. The four-valued value `(true, true)` is a direct counterexample to extending that claim beyond Boolean complementation.

For explosion, the Liar is both derivable and its own syntactic negation, while the false witness has no derivation. Thus the representative contradiction fails to derive the chosen arbitrary false sentence.

## Boundary table

| Property | Boolean nontrivial semantics | Four-valued witness |
|---|---:|---:|
| designated negation fixed point | impossible | exists |
| three distinct theorem gluts | impossible under fixed-point reading | exists |
| explicit non-designated sentence | possible | exists |
| explosion from a glut | classical contradiction collapses consequence | refuted by false witness |

These calculations are certificates for the finite construction; they do not test unrestricted natural-language truth, comprehension, or description syntax.
