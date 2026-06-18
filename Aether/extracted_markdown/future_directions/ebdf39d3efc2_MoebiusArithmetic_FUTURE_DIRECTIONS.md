# Future Directions: Arithmetic on the Moebius Band

Research cycle 1 established the **Moebius integers** `𝕄 = ℤ ⋊ ℤ`, the twisted
number system whose group law carries the monodromy sign `twist(p) = (-1)^p` of
the Moebius band. We proved it is a torsion-free, non-commutative group (the
Klein-bottle group), characterized its center, and identified the transverse
fiber as a normal subgroup equal to the kernel of the loop projection.

Below are bold, falsifiable conjectures for follow-up cycles.

## C1. Exact structure of the abelianization
**Conjecture.** The abelianization `𝕄 / [𝕄, 𝕄]` is isomorphic to `ℤ × ℤ/2ℤ`.
*Rationale.* The commutator `[(1,0),(0,1)] = (0,-2)` shows the commutator
subgroup is `{(0, 2k)}`, the even transverse motions. Quotienting collapses the
fiber to `ℤ/2ℤ` while leaving the loop `ℤ` free. *Test.* Build the commutator
subgroup `2·heightSubgroup` and prove a `MulEquiv` to `Multiplicative (ℤ × ZMod 2)`.

## C2. The conjugacy class spectrum
**Conjecture.** Two elements `(p,h)` and `(p',h')` of `𝕄` are conjugate iff
`p = p'` and (i) for even `p`, `h = h'`; (ii) for odd `p`, `h ≡ h' (mod 2)`.
*Rationale.* Conjugation by `(1,0)` sends `(p,h) ↦ (p, twist? ...)`; for odd `p`
the twist mixes heights with a fixed parity invariant. *Test.* Define the
conjugacy relation and prove this characterization; deduce that odd-loop classes
are exactly two per loop value.

## C3. Generalized monodromy: the `r`-twisted band over `ℤ/mℤ` fibers
**Conjecture.** Replacing the fiber `ℤ` by `ℤ/mℤ` and the sign by an order-`d`
automorphism (`twist^d = id`) yields a group `𝕄(m,d)` that is finite of order
`m·d`·(loop period), and is non-abelian exactly when `d > 1` and `m > 2`.
*Rationale.* This interpolates between the cylinder (`d=1`) and the Moebius band
(`d=2`). *Test.* Formalize `𝕄(m,d)` as a semidirect product `ZMod m ⋊ ZMod (d·?)`
and prove the non-abelian criterion and a Lagrange-style order formula.

## C4. No faithful 1-dimensional twist (representation obstruction)
**Conjecture.** `𝕄` admits no injective homomorphism into any abelian group;
equivalently, every homomorphism `𝕄 → A` (A abelian) factors through `loopHom`
composed with the abelianization, killing the odd part of the fiber.
*Rationale.* The relation `x y x⁻¹ = y⁻¹` forces `y² ↦ image`'s order-2 collapse.
*Test.* Prove `∀ (A : Type) [CommGroup A] (f : 𝕄 →* A), (0,1) and (0,-1) have equal image`,
and conclude non-injectivity of any such `f`.

## C5. Arithmetic dynamics of the twist map (Collatz-style orbit question)
**Conjecture.** Iterating left-multiplication by the generator `g = (1,0)` on a
seed `(0,h)` produces orbits whose height-sequence is exactly `h, -h, h, -h, …`
(pure period 2), and more generally the height of `gⁿ · (0,h)` is `(-1)ⁿ h`.
*Rationale.* The monodromy acts as an involution on the fiber. *Test.* Prove
`(g^n * ⟨0,h⟩).height = (-1)^n * h` by induction, establishing the band's
"period-2 arithmetic" rigorously, and explore whether composite twist seeds
`(1,h)` give unbounded vs. bounded height orbits (they grow linearly — verify).
