/-
# A4-FORK-PINNING: the first cubic-pinned non-abelian fork

Umbrella module for the formal development of the `A₄` fork-pinning experiment
(paper 75, experiment 410).  See the individual files for the mathematics:

* `Algebra.A4ForkPinning.Information` — bit-valued information calculus and the
  pinned / flat / leaking trichotomy;
* `Algebra.A4ForkPinning.GroupA4` — `V₄ = [A₄,A₄]`, `|A₄^ab| = 3`, the cubic
  character of `A₄`, the `[4,1,0]` root signature, within-`V₄` flatness;
* `Algebra.A4ForkPinning.Resolvent` — the Klein resolvent `y³-48y-64` of
  `x⁴+8x+12`, discriminant `576²`, identification with the conductor-`9` cyclic
  cubic `ℚ(ζ₉)⁺`, irreducibility, and the cubic residues mod `9`;
* `Algebra.A4ForkPinning.Character` — both characters bundled, and
  `A₄^ab ≃* (ℤ/9)ˣ / cubes`;
* `Algebra.A4ForkPinning.Pinning` — `I(p mod 9 ; F₀) = H(1/3)` and the exact
  leakage law of the identity fork;
* `Algebra.A4ForkPinning.Semiprime` — the order-3 channel at semiprime level;
* `Algebra.A4ForkPinning.MultiFactor` — the `k`-factor AND law and its collapse;
* `Algebra.A4ForkPinning.Unpinnable` — the pinning-content criterion and the
  absolutely unpinnable `A₅` case.
-/
import Algebra.A4ForkPinning.Information
import Algebra.A4ForkPinning.GroupA4
import Algebra.A4ForkPinning.Resolvent
import Algebra.A4ForkPinning.Character
import Algebra.A4ForkPinning.Pinning
import Algebra.A4ForkPinning.Semiprime
import Algebra.A4ForkPinning.MultiFactor
import Algebra.A4ForkPinning.Unpinnable