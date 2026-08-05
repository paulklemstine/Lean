# Computational evidence

All computations below were run in Lean (`#eval`) before the formal development; the
statements they support are *proved* in the accompanying `.lean` files, so the numbers are
sanity checks rather than the final justification.

## 1. The main claim being tested

For a connected groupoid `C` (an algebraic model of a `K(G,1)`, `G = π₁(C,c)`), the group
of homotopy classes of self-homotopy-equivalences should be `Out G = Aut G / Inn G`, and
the *monoid* of homotopy classes of all self-maps should be `End G / conjugation`.

Small-case predictions of this claim:

| `G` | `Inn G` | predicted `hAut = Out G` | predicted `#hAut` |
|---|---|---|---|
| `1` | `1` | `1` | 1 |
| `ℤ` | `1` (abelian) | `Aut ℤ = {±1}` | 2 |
| `ℤ/n` | `1` (abelian) | `(ℤ/n)ˣ` | `φ(n)` |
| `(ℤ/2)²` | `1` (abelian) | `GL₂(𝔽₂) ≅ S₃` | 6 |
| discrete set `α` (all `π₁` trivial) | — | `Sym(α)` | `#α !` |

## 2. Cyclic case: `#hAut(K(ℤ/n,1)) = φ(n)`

Brute-force count of invertible residues mod `n` (i.e. of automorphisms of `ℤ/n`)
against Euler's totient:

```lean
def numUnits (n : ℕ) : ℕ := ((List.range n).filter (fun a => Nat.gcd a n = 1)).length
#eval (List.range' 1 15).map (fun n => (n, numUnits n, Nat.totient n,
        decide (numUnits n = Nat.totient n)))
```

Output:

```
[(1,1,1,true), (2,1,1,true), (3,2,2,true), (4,2,2,true), (5,4,4,true), (6,2,2,true),
 (7,6,6,true), (8,4,4,true), (9,6,6,true), (10,4,4,true), (11,10,10,true), (12,4,4,true),
 (13,12,12,true), (14,6,6,true), (15,8,8,true)]
```

So the predicted counts of homotopy classes of self-homotopy-equivalences of
`K(ℤ/n,1)` for `n = 1,…,15` are

```
1, 1, 2, 2, 4, 2, 6, 4, 6, 4, 10, 4, 12, 6, 8
```

which is Euler's totient sequence (OEIS **A000010**, first terms
`1, 1, 2, 2, 4, 2, 6, 4, 6, 4, 10, 4, 12, 6, 8, …`).  This is
`FundamentalGroupCyclic.card_hEnd_units_cyclicModel`.

## 3. Circle case: degrees

For `G = ℤ` the monoid `End ℤ` is `(ℤ, ·)`, so composition of self-maps of `K(ℤ,1)`
should multiply degrees and the invertible classes should be exactly `±1`:

```lean
#eval [((2:ℤ)*3, (3:ℤ)*2), ((-1)*(-1), 1)]   -- (6, 6), (1, 1)
```

Only `1` and `-1` are units of `(ℤ, ·)`, predicting exactly two self-homotopy
equivalences of the circle model.  Proved as
`FundamentalGroupOut.card_hEnd_units_circleModel`,
`FundamentalGroupOut.degree_comp` and
`FundamentalGroupOut.isEquivalence_circle_iff_degree`.

## 4. Klein four group

For `G = (ℤ/2)²` (abelian, so `Out G = Aut G = GL₂(𝔽₂)`), a brute-force count of the
linear automorphisms — a linear endomorphism is determined by the images `u, v` of the two
basis vectors, and is invertible iff `u ≠ 0`, `v ≠ 0`, `u ≠ v`:

```lean
#eval ((List.range 4).flatMap (fun u => (List.range 4).map (fun v => (u, v)))).filter
    (fun p => (p.1 != 0) && (p.2 != 0) && (p.1 != p.2)) |>.length   -- 6
```

so `#hAut(K((ℤ/2)²,1)) = 6`, consistent with `Aut((ℤ/2)²) ≅ S₃`.

## 5. Counterexample hunt

* **Is connectedness needed?**  Yes.  For the discrete 1-type on a set `α` all fundamental
  groups are trivial, yet `hAut = Sym(α)`, which is huge; so `Out(π₁)` alone cannot be the
  answer without connectedness.  Formalised as
  `FundamentalGroupPi0SelfEquiv.hEndDiscreteUnitsMulEquivPerm` (and matching the
  `π₁`-does-not-classify counterexamples in the earlier files of this project).
* **Is `Aut G` (rather than `Out G`) the answer?**  No: for `G` with nontrivial centre-free
  inner automorphisms the conjugation action is not trivial on homotopy classes; the
  general theorem shows the kernel of `Aut G → hAut` is *exactly* `Inn G`
  (`FundamentalGroupOut.ker_autToConjEndUnit`).  For abelian `G` the two answers agree,
  which is why all the numerical examples above are `Aut`-counts.
* **Could a non-invertible endomorphism give a homotopy equivalence?**  No — searched
  conceptually and proved: `FundamentalGroupOut.bijective_of_isUnit_conjEnd_mk` shows an
  endomorphism whose conjugacy class is invertible is already bijective (the circle case is
  the familiar statement that only degree `±1` maps are equivalences).

No counterexample to the main claim was found; all small cases match.

## 6. Evidence for the wreath-product theorem (this cycle)

The new claim is that for a disjoint union of `ι` copies of a `K(G,1)`,

  `hAut(⊔_ι K(G,1)) ≅ Out(G) ≀ Sym(ι) = (ι → Out G) ⋊ Sym(ι)`,

so that for finite `ι` the count should be `|Out G| ^ |ι| · |ι|!`.  Predictions for small
cases, all of which are now theorems:

| `G` | `|Out G|` | `|ι|` | predicted `#hAut(⊔_ι K(G,1))` | theorem |
|---|---|---|---|---|
| `1` | 1 | `n` | `n!` | `hAutTrivialPiOneMulEquivPerm` |
| any | `k` | 1 | `k` | `hAutSingleCopyMulEquivOut` |
| `S₃` | 1 | 3 | `6` | `card_hAut_three_copies_symmetricGroupThree` |
| `(ℤ/2)²` | 6 | 2 | `72` | `card_hAut_two_copies_kleinFour` |
| `ℤ/5` | 4 | `n` | `4^n · n!` | `card_hAut_sigma_of_card_hAut` |

The two group-theoretic inputs for the nonabelian examples were first checked by finite
computation and are now proved by kernel-checked `decide`:

```lean
-- every automorphism of S₃ is inner  (720 candidate bijections of a 6-element group)
example : ∀ f : MulAut (Equiv.Perm (Fin 3)), ∃ x, ∀ a, f a = x * a * x⁻¹ := by decide
-- Aut of the Klein four group has 6 elements and is nonabelian
example : Nat.card (MulAut (Multiplicative (ZMod 2 × ZMod 2))) = 6 := by
  simp only [Nat.card_eq_fintype_card]; decide
example : ¬ ∀ x y : MulAut (Multiplicative (ZMod 2 × ZMod 2)), x * y = y * x := by decide
```

Counterexample hunt for the wreath claim: the obvious weaker guesses fail, and the file
records why.  The *direct product* `(ι → Out G) × Sym(ι)` is not the answer — the
extension is genuinely twisted, as the multiplication rule
`(P, σ)(Q, τ) = (fun i => P (τ i) * Q i, σ ∘ τ)` of `WreathEnd` shows — while the
*monoid* of all self-maps is strictly larger than its unit group whenever `End(G)/conj`
has non-invertible elements (e.g. degree `0` for `G = ℤ`), so no formulation in terms of
`Out` alone can classify self-maps.

## Heterogeneous components: small-case evidence

The general matrix-monoid theorem is structural rather than a finite conjecture, but its
smallest non-constant example gives a useful check.  For
`K(ℤ,1) ⊔ K(ℤ/3,1)` the two components cannot be interchanged (their fundamental groups
have different cardinalities), while both outer automorphism groups have order two.
Consequently the theorem predicts

| component family | permitted component permutations | kernel | `#hAut` |
|---|---:|---:|---:|
| `K(ℤ,1) ⊔ K(ℤ/3,1)` | 1 | `2 · 2` | 4 |
| two copies of `K(ℤ/3,1)` | 2 | `2 · 2` | 8 |
| three pairwise inequivalent rigid components | 1 | 1 | 1 |

The first row is now kernel-checked as
`FundamentalGroupHeteroExamples.card_hAut_twoPieces`; the proof also establishes directly
that an equivalence between its two components would induce an impossible equivalence of
an infinite group with the three-element group.  The second row is the `n = 2` instance of
the already proved constant-family wreath formula `|Out G|^n · n!`.  No OEIS search is
relevant: these are consequences of a structural classification, not a newly observed
integer sequence.  The counterexample hunt confirms that replacing the subgroup
`Sym'(π₀)` by all of `Sym(π₀)` is false for a heterogeneous family: the transposition in
the first row is not realised.
