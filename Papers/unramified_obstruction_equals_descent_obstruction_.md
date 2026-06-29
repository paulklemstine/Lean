# Computational Evidence: obstruction equality is a closure identity

The conjecture "unramified obstruction = descent obstruction" is, at the level of
arithmetic geometry over a p-adic function field, far beyond direct computation:
its objects (étale cohomology `H³_nr(X, ℚ/ℤ(2))`, adelic spaces `X(A_K)`) are not
finite. We therefore test the **structural reduction** proved in this cycle:

> Each obstruction is the left orthogonal `H^⊥ ⊆ S` of a family `H` of cohomology
> classes under a biadditive reciprocity pairing `S × B → C`. Two families cut out
> the same obstruction set iff they have the same double-orthogonal closure, and
> `Hdesc ⊆ Hunr ⊆ clB(Hdesc)` already forces `Hunr^⊥ = Hdesc^⊥`.

The finite analogue is fully computable, and we use it to (a) confirm the
comparison theorem is non-vacuous and (b) hunt for counterexamples to the soft
claims.

## 1. The toy model over ℤ/4

Take `S = B = C = ℤ/4`, pairing `⟨s, b⟩ = (2s)·b`, descent classes
`Hdesc = {1}`, unramified classes `Hunr = {1, 2}`.

| element s | ⟨s,1⟩ = 2s | in Hdesc^⊥ ? | ⟨s,2⟩ = 4s = 0 | in Hunr^⊥ ? |
|-----------|------------|--------------|-----------------|-------------|
| 0         | 0          | yes          | 0               | yes         |
| 1         | 2          | no           | 0               | no          |
| 2         | 0          | yes          | 0               | yes         |
| 3         | 2          | no           | 0               | no          |

* `Hdesc^⊥ = {0, 2}` and `Hunr^⊥ = {0, 2}`: **equal**, as the theorem predicts.
* `Hdesc = {1} ⊊ {1, 2} = Hunr`: the class families are genuinely different, so
  the equality of obstruction sets is a real coincidence, not a renaming.
* The common obstruction set `{0, 2}` is a **proper nonempty** subset of `ℤ/4`
  (`0` in, `1` out), so the pairing is nondegenerate enough to be interesting.

This is exactly the certified content of `model_equal`, `model_proper`,
`model_zero_mem`, `model_one_not_mem` in `UnramifiedDescentModel.lean`.

## 2. Why the closure hypothesis is the whole game

`1` generates all of `ℤ/4`, hence `2 = 1 + 1 ∈ ⟨Hdesc⟩ ⊆ clB(Hdesc)`. The
hypothesis `Hunr ⊆ clB(Hdesc)` therefore holds, and equality of obstruction sets
follows formally. If instead we had used a pairing for which `2 ∉ clB({1})`, the
two obstruction sets could differ — see the counterexample hunt below.

## 3. Counterexample hunt: can the obstructions differ?

We searched small finite pairings `S × B → C` for the *necessity* of the closure
hypothesis, i.e. for `Hdesc ⊆ Hunr` with `Hdesc^⊥ ≠ Hunr^⊥`.

* `B = ℤ/2 × ℤ/2`, `S = B`, perfect pairing `⟨s,b⟩ = s₁b₁ + s₂b₂ ∈ ℤ/2`.
  Take `Hdesc = {(1,0)}`, `Hunr = {(1,0),(0,1)}`. Then `clB({(1,0)}) =
  ⟨(1,0)⟩ = {(0,0),(1,0)}`, which does **not** contain `(0,1)`, so the closure
  hypothesis fails. Indeed `Hdesc^⊥ = {(s₁,s₂) : s₁ = 0}` (2 elements) while
  `Hunr^⊥ = {(0,0)}` (1 element): the obstructions **differ**.

  Interpretation: dropping the closure hypothesis genuinely breaks the equality,
  confirming the theorem's hypothesis is load-bearing and not vacuous.

* When the pairing is the trivial pairing (`⟨s,b⟩ = 0` for all `s,b`), every
  family has orthogonal `S`, so all obstructions agree trivially — a degenerate
  boundary case that the closure description handles uniformly (`clB(∅) = B`).

No counterexample was found to the **proved** statement
`Hdesc ⊆ Hunr ⊆ clB(Hdesc) ⟹ Hdesc^⊥ = Hunr^⊥`; every finite instance tested
respected it, as it must, since it is a theorem.

## 4. OEIS / external signals

No integer sequence is intrinsic to the comparison itself (the objects are
orthogonal complements, not counts). The relevant external signal is the
cohomological-dimension arithmetic `cd(p-adic field) = 2`, `cd(function field of a
curve over it) = 2 + 1 = 3`, which singles out degree-three unramified cohomology
`H³_nr(–, ℚ/ℤ(2))` as the correct replacement for the Brauer group `H²_nr` used
over number fields. This `2 + 1 = 3` ceiling drives Conjectures 1 and 5 in
`FUTURE_DIRECTIONS.md` and the recent arXiv activity (arXiv:2412.17486) on
obstructions over such fields motivated the choice of target.

## 5. Summary

The finite computations confirm: (i) the comparison theorem is non-vacuous with
strictly different class families; (ii) the closure hypothesis is necessary, with
an explicit `ℤ/2 × ℤ/2` instance where dropping it makes the obstructions differ;
(iii) the equality, when the hypothesis holds, is forced by the Galois-connection
formalism alone. This is exactly the split between formal skeleton and geometric
input that the Lab Notes describe.
