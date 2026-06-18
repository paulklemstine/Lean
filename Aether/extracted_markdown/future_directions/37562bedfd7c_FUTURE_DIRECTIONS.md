# Future Directions — Arithmetic Mirror Symmetry for Calabi–Yau

## Synthesis

This cycle formalized the **topological mirror test** for Calabi–Yau manifolds in
`Catalog/Applications/ArithmeticMirrorSymmetry.lean`: the integer Hodge data of a
complex `n`-fold (`HodgeDiamond n`), the Hodge reflection `mirror` (`h^{p,q} ↦
h^{n-p,q}`), and the Euler characteristic `euler`. The core result `euler_mirror`
proves `χ(X̌) = (-1)^n χ(X)` purely as a **reindexing identity** for the involution
`Fin.rev` together with the sign law `(-1)^{(n-p)+q} = (-1)^n (-1)^{p+q}`; it needs no
Calabi–Yau or Serre-duality hypotheses. Specializing to 3-folds gives the sign flip
`euler_mirror_odd`, the closed form `euler_cy3 : χ = 2(h^{1,1} - h^{2,1})`, the
exchange theorem `cy3_mirror_swap : mirror (cy3Diamond a b) = cy3Diamond b a`, and the
quintic / mirror-quintic witnesses `χ = ∓200`.

This connects naturally to the catalog's `Applications/SmoothPoincare/IntersectionForms.lean`
(unimodular symmetric integer forms, Euler/signature data of 4-manifolds): both
develop *integer lattice invariants of manifolds* and the obstructions a symmetry
must respect. The Hodge-diamond framework here is the even-dimensional, complex-analytic
analogue of the intersection-form story there.

## Results Summary

- `mirror_mirror` — the mirror map is an involution.
- `euler_mirror` — `χ(X̌) = (-1)^n · χ(X)` (general dimension, no extra hypotheses).
- `euler_mirror_odd` — sign flip `χ(X̌) = -χ(X)` for odd `n` (CY 3-folds).
- `cy3_mirror_swap` — mirror swaps `h^{1,1} ↔ h^{2,1}` for a CY 3-fold.
- `euler_cy3` — `χ = 2(h^{1,1} - h^{2,1})`.
- `quintic_euler`, `mirror_quintic_euler` — `χ = -200`, mirror `χ = +200`.

All proofs are `sorry`-free and depend only on `propext`, `Classical.choice`, `Quot.sound`.

## Research Directions

### 1. Hodge–Poincaré (E-)polynomial mirror duality
The Euler characteristic is the value at `(1,1)` of the Hodge–Poincaré polynomial
`E(u,v) = Σ (-1)^{p+q} h^{p,q} u^p v^q`. The conjecture is that the mirror reflection
acts on this two-variable refinement by `E_{X̌}(u,v) = (-u)^n E_X(u^{-1}, v)` (variable
swap on the `p`-grading), recovering `euler_mirror` at `u=v=1` as a single specialization.
**The key insight is** that the Euler sign rule already proved is the `u=v=1` shadow of a
*polynomial* identity, so it should lift verbatim by carrying the monomial `u^p` through
the same `Fin.rev` reindexing. **Why now?** `euler_mirror` shows the reindexing machinery
works and isolates exactly the sign bookkeeping; promoting the scalar `(-1)^{p+q}` to a
monomial is a mechanical strengthening that reuses the proven `Equiv.sum_comp` step.

### 2. Stringy Euler numbers of crepant resolutions and orbifold mirrors
Batyrev's stringy Euler number `χ_st` of a Gorenstein orbifold equals the ordinary Euler
number of any crepant resolution and is the invariant that is genuinely mirror-antisymmetric
for *singular* Calabi–Yau (where naive Hodge numbers fail). The conjecture: for a finite
group `G` acting on a `HodgeDiamond`, an orbifold-corrected Euler number `χ_orb = Σ_{[g]}
χ(fixed data)` satisfies the same `(-1)^n` mirror law. **The key insight is** that the
ordinary `euler` is the `g = 1` term of the orbifold sum, so the mirror law extends termwise
if each twisted sector carries a reflected Hodge sub-diamond. **Why now?** The clean
`HodgeDiamond`/`mirror` API makes "sum over a group of reflected sub-diamonds" expressible
directly, and the catalog already hosts substantial finite-group machinery to borrow.

### 3. Arithmetic point-count congruences (Candelas–de la Ossa–Rodriguez-Villegas)
The deepest form of mirror symmetry is arithmetic: for a mirror pair over `𝔽_p` the unit
roots of the congruence zeta functions coincide, giving `#X_ψ(𝔽_p) ≡ #X̌_ψ(𝔽_p) (mod p)`.
The falsifiable conjecture is a *computable* instance: for the Dwork pencil of elliptic
curves `x³+y³+z³ = 3ψ xyz` over `ZMod p`, the projective point count mod `p` is mirror
invariant for all small `p` and `ψ`. **The key insight is** that point counts over `ZMod p`
are `Finset.card` of a decidable predicate, hence verifiable by `decide` for fixed small
`p`, turning a transcendental zeta-function statement into a finite check. **Why now?** The
present file already commits to a *computable* philosophy (Euler numbers by `decide`/`rfl`);
extending from Hodge data to finite-field point counts is the natural bridge from the
topological test to genuine arithmetic mirror symmetry.

### 4. Mirror symmetry as a signed-permutation symmetry of the Euler pairing
View `euler` as a bilinear-style functional on the lattice of Hodge data; `mirror` is then
the linear involution `Fin.rev ⊗ id`. The conjecture: the only `ℤ`-linear involutions of
`HodgeDiamond n` that send `euler ↦ ±euler` are exactly the index reflections (`Fin.rev` on
either factor) and their composite, i.e. mirror symmetry is *forced* by demanding an Euler
sign symmetry. **The key insight is** that `euler_mirror`'s proof used nothing about `Fin.rev`
except that it is a sign-reversing involution on the grading, so a converse classification
should hold. **Why now?** With `euler_mirror` proven, the remaining work is a finite linear-
algebra classification over `Fin (n+1) × Fin (n+1)`, fully within reach of decision procedures
for fixed `n`.

### 5. The 24-cell / Euler-bound rigidity for self-mirror Calabi–Yau
A Calabi–Yau 3-fold is *self-mirror* exactly when `h^{1,1} = h^{2,1}`, forcing `χ = 0` by
`euler_cy3`. The conjecture: among `cy3Diamond a b` with `0 ≤ a, b` and a fixed bound on
`a + b`, the self-mirror locus `a = b` is precisely the zero set of `euler`, and the map
`χ/2 = a - b` is a complete invariant of the mirror orbit `{(a,b), (b,a)}`. **The key insight
is** that `euler_cy3` makes `χ` a *linear* coordinate on the `(h^{1,1}, h^{2,1})` plane, so
mirror orbits are the level sets of `|χ|` and the self-mirror locus is the unique fixed line.
**Why now?** `euler_cy3` and `cy3_mirror_swap` together already pin down the orbit structure;
formalizing the invariant-completeness statement is a short, decidable consequence and would
give a clean rigidity theorem to seed the next cycle.
