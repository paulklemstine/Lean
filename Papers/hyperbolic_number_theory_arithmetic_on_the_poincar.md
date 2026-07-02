# Hyperbolic Integer Arithmetic: What Is Rigorous and What Is Ill-Posed

This note accompanies `Catalog/Geometry/HyperbolicDisk/Integers.lean` (and the pre-existing
`Core.lean`). It records, honestly, which parts of the requested "hyperbolic integer arithmetic"
programme are genuine mathematics — formalized and proved in Lean — and which parts are, as
literally stated, mathematically ill-posed or false. Where a request is false, the Lean file
proves the corrected statement or the impossibility, rather than papering over the gap.

Every claim below marked **[proved]** corresponds to a `sorry`-free Lean theorem whose only
axioms are `propext`, `Classical.choice`, `Quot.sound`.

---

## 1. Models of ℍ² and the coordinate transform — genuine

* Poincaré disk `InUnitDisk z := normSq z < 1` and upper half-plane `InUpperHalf z := 0 < im z`.
* Cayley transform `cayley z = (z - i)/(z + i)` and inverse `invCayley w = i(1+w)/(1-w)`.

**[proved]** `cayley_mem_disk`: the Cayley map sends the half-plane into the disk.
**[proved]** `invCayley_cayley`, `cayley_invCayley`: the two maps are mutually inverse (away from
their poles `z = -i` and `w = 1`), i.e. an explicit biholomorphic identification of the two models.

This is exactly the requested "explicit coordinate transformations" and it is fully correct.
(`Core.lean` additionally develops the Blaschke disk-automorphism identity, Einstein addition on
`(-1,1)`, the rapidity isomorphism, and Chebyshev trace–distance duality.)

---

## 2. The Fuchsian group Γ — corrected: **Γ(2) is not cocompact**

The request asks for a *cocompact, torsion-free* Fuchsian group and offers "Γ(2) or a Schottky
group" as examples. This is internally inconsistent:

* **Γ(2) is a lattice but NOT cocompact.** Its quotient `ℍ²/Γ(2)` is a thrice-punctured sphere:
  finite area, but *non-compact* — it has cusps. A Fuchsian group is cocompact iff it has no
  parabolic elements; Γ(2) has plenty.
* **Schottky groups are not cocompact either.** A (classical, purely hyperbolic) Schottky group is
  free, discrete and torsion-free, but *convex-cocompact of infinite covolume*: its quotient is an
  infinite-area surface with funnels, never compact.
* There is no *simple explicit* family of matrices generating a cocompact torsion-free Fuchsian
  group; the standard constructions (surface groups) come from unit groups of quaternion algebras
  and are not writable as a couple of small integer matrices.

We therefore use the honest object `Γ(2) = CongruenceSubgroup.Gamma 2 ⊆ SL(2,ℤ) ⊆ SL(2,ℝ)` and
prove the facts that *witness the failure of cocompactness*:

**[proved]** `genT_mem`, `genS_mem`: the standard generators `T = [[1,2],[0,1]]`,
`S = [[1,0],[2,1]]` lie in Γ(2).
**[proved]** `genT_trace`: `tr(T) = 2`, so `T` is **parabolic**.
**[proved]** `genT_pow`: `Tⁿ = [[1,2n],[0,1]]`, hence
**[proved]** `genT_infinite_order`: `T` has infinite order.

A parabolic element forces a cusp, so Γ(2) is not cocompact. (Γ(2) *is* torsion-free — a genuine
classical theorem — but that is orthogonal to the false cocompactness claim, so we do not rely on
it.)

---

## 3. The hyperbolic integers `Z_H = ℤ² / Γ(2)` — genuine

Γ(2) acts linearly on the integer lattice `ℤ²`. Two vectors are equivalent iff they lie in the
same orbit.

**[proved]** `ZHrel_refl`, `ZHrel_symm`, `ZHrel_trans`: the orbit relation is an equivalence
(reflexivity via `1`, symmetry via `γ⁻¹ ∈ Γ(2)`, transitivity via `δγ ∈ Γ(2)` and
`(δγ) *ᵥ v = δ *ᵥ (γ *ᵥ v)`).

This gives a well-defined quotient type `Z_H := Quotient ZHsetoid` with quotient map `toZH`.
This is the "orbit of the integer lattice under the (linear) group action" as requested.

---

## 4. Discreteness of `Z_H` — genuine

Every hyperbolic integer is represented by a lattice point, and the lattice is discrete.

**[proved]** `lattice_ball_finite`: for every `R`, the set `{ v ∈ ℤ² | v₀² + v₁² ≤ R }` is finite.

This is the precise content of "`Z_H` forms a discrete set": each metric ball contains only
finitely many representatives.

---

## 5. "Addition = geodesic midpoint" — corrected: **it is the geometric mean, and it is not a group**

On the imaginary-axis geodesic `{ i·s : s > 0 }` the hyperbolic distance is
`d(i·s, i·t) = |log t − log s|`, so the unique hyperbolic midpoint of `i·s` and `i·t` is `i·√(s·t)`
— the **geometric mean**. We define `hMid s t := √(s·t)` and `axisDist s t := |log t − log s|`.

**[proved]** `hMid_equidistant`: `√(s·t)` is genuinely equidistant from `s` and `t`; it is the
correct geodesic midpoint.
**[proved]** `hMid_comm`, `hMid_idem`: the operation is commutative and idempotent (`hMid s s = s`).
**[proved]** `hMid_not_assoc`: it is **not associative** (`√(√(1·4)·16) = √32 ≠ √8 = √(1·√(4·16))`).

Consequences, which is why the downstream requests collapse:

* Associativity already fails, so `hMid` is **not** an (additive) group operation.
* **[proved]** `idempotent_group_trivial`: abstractly, *any* idempotent group operation forces a
  one-element group. Since the geodesic has more than one point and the midpoint is idempotent,
  the midpoint can never be a group law.

Therefore there is **no** induced additive group on `Z_H` coming from geodesic midpoints, hence no
ring, hence:

> **"Unique factorization theorem for hyperbolic integers" is not well-posed.** There is no
> multiplication and no factorization relation to make it about. This is an impossibility result,
> not a missing proof.

(The "midpoint" is a legitimate and useful *mean* operation — commutative, idempotent, with the
equidistance property — just not an arithmetic of a ring.)

---

## 6. "Multiplication via the cross-ratio" — genuine content, but still not a ring product

The cross-ratio `crossRatio a b c d = ((a−c)(b−d))/((a−d)(b−c))` is the fundamental Möbius
invariant.

**[proved]** `mob_diff`, `crossRatio_mob_invariant`: the cross-ratio is invariant under every
Möbius transformation `z ↦ (αz+β)/(γz+δ)` with `αδ−βγ ≠ 0`. Isometries of ℍ² are the special case
`α,β,γ,δ ∈ ℝ`, `αδ−βγ = 1`.

This is the genuine geometric object behind "hyperbolic multiplication via the cross-ratio". But
invariance of a four-point functional is **not** a binary multiplication on `Z_H`, and it does not
supply associativity, an identity, or inverses. So it does not upgrade `Z_H` to a ring either.

---

## 7. "Primes = Dirichlet cells with exactly 4 sides" — corrected: **degenerate**

For a cocompact torsion-free Fuchsian group, the group permutes the Dirichlet cells transitively
by isometries, and isometries preserve the number of sides of a cell. Any action-invariant
property of a cell is therefore all-or-nothing.

**[proved]** `transitive_invariant_dichotomy`: if a group acts transitively on `X` and `f : X → ℕ`
is invariant, then `{x | f x = k}` is either `∅` or `Set.univ`.

Applied with `f =` (number of sides of the Dirichlet cell) and `k = 4`, the set of "4-sided cells"
is empty or everything. So the proposed definition of "hyperbolic prime" can never carve out a
proper, nonempty subset:

> **The "hyperbolic prime" definition is degenerate**, and the requested "asymptotic counting
> theorem for hyperbolic primes" has no well-defined object to count. (The genuine analytic object
> in this circle of ideas — the *prime geodesic theorem*, counting primitive closed geodesics by
> length — is a deep theorem not currently in Mathlib and is unrelated to "4-sided cells".)

---

## Summary

| Requested item | Status | Lean witness |
|---|---|---|
| Upper half-plane & disk models, coordinate transform | genuine, proved | `cayley_mem_disk`, `invCayley_cayley`, `cayley_invCayley` |
| Cocompact torsion-free Fuchsian Γ (Γ(2) / Schottky) | **false as stated**; Γ(2) not cocompact | `genT_trace`, `genT_infinite_order` |
| `Z_H = ℤ²/Γ` orbit quotient | genuine, proved | `ZHrel_*`, `Z_H`, `toZH` |
| `Z_H` discrete | genuine, proved | `lattice_ball_finite` |
| Addition = geodesic midpoint (a group?) | midpoint genuine; **not a group** | `hMid_equidistant`, `hMid_idem`, `hMid_not_assoc`, `idempotent_group_trivial` |
| Multiplication via cross-ratio | invariance genuine; **not a ring product** | `crossRatio_mob_invariant` |
| Primes = 4-sided Dirichlet cells | **degenerate** (empty or all) | `transitive_invariant_dichotomy` |
| Asymptotic prime count | **ill-posed** (no primes defined) | — |
| Unique factorization for `Z_H` | **ill-posed** (no ring) | — |

The file contains no `sorry` and no added axioms.
