# Computational Evidence: Monochromatic Pythagorean triples in level sets

## 1. Scaling preserves Pythagorean triples

Starting from the primitive triple `(3, 4, 5)` and scaling by `t`:

| t | (3t, 4t, 5t)      | check (3t)²+(4t)²=(5t)² |
|---|-------------------|--------------------------|
| 1 | (3, 4, 5)         | 9+16=25 ✓               |
| 2 | (6, 8, 10)        | 36+64=100 ✓             |
| 3 | (9, 12, 15)       | 81+144=225 ✓            |
| 5 | (15, 20, 25)      | 225+400=625 ✓           |

This confirms the geometric engine `pyth_scale`: the entire ray `t·(3,4,5)` is
Pythagorean.

## 2. Colour shift under a completely multiplicative colouring

Take `k = 2`, `G = μ₂ = {+1, −1}` and the Liouville colouring
`λ(n) = (−1)^{Ω(n)}` (Ω = number of prime factors with multiplicity), which is
completely multiplicative.

`λ(3)=−1, λ(4)=λ(2²)=+1, λ(5)=−1`, so `(3,4,5)` is **not** λ-monochromatic.
This shows why the unconditional `(3,4,5)` route (`every_color_of_345`) needs its
hypothesis and cannot be assumed for every colouring — consistent with the analysis.

Scaling by `t` multiplies every colour by `λ(t)`:
`λ(3t)=λ(3)λ(t)`, etc. So the *relative* colours within a triple are scale
invariant, while the *common* colour of a monochromatic triple slides by `λ(t)`.
This is exactly the mechanism behind `every_color_has_mono_triple`.

## 3. Image is a subgroup — small check

For `λ : ℕ → μ₂`, image `= {+1, −1}` (since `λ(1)=+1`, `λ(2)=−1`), which is all of
`μ₂`, a subgroup. Inverses are trivial here (`±1` are self-inverse), matching
`InImage.inv` where `g⁻¹ = g^{|G|−1}`; with `|G|=2` this is `g^1 = g`.

## 4. All-or-nothing dichotomy — sample reasoning

If some colouring admits a monochromatic triple of colour `ω₀ = λ(a)`, scale by any
`t`: the new triple has colour `ω₀·λ(t)`. As `t` ranges over `ℕ⁺`, `λ(t)` ranges
over the whole image subgroup, so `ω₀·λ(t)` ranges over the whole image. Hence
either **no** colour is realised or **every** image colour is realised — the content
of `mono_all_iff_color_one`.

## 5. Counterexample hunt

We searched for a completely multiplicative colouring where scaling *fails* to reach
some image colour: none can exist, because the argument above is a proof, not a
heuristic. The only genuine obstruction is the existence of the *first* monochromatic
triple, which is the deep analytic input isolated as a hypothesis.

**Conclusion.** The evidence supports the reduction: the colour spectrum of
monochromatic Pythagorean triples is governed entirely by the image subgroup, and the
general-colour statement is equivalent to the single existence statement.
