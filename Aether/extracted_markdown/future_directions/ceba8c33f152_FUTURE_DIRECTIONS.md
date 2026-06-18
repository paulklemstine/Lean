# Future Directions — Arithmetic-Height-Induced Ultrametrics

## Synthesis

The new file `Bridges/ArithmeticHeightUltrametric.lean` builds a concrete pipeline
from *arithmetic height / p-adic depth data* to the catalog's categorical
tropical–ultrametric object layer (`Bridges/CategoricalTropicalUltrametric.lean`).
Two complementary faces of the same nonarchimedean idea are formalized:

1. **A quantitative real-valued ultrametric on ℚ.** `hDist p x y := padicNorm p (x - y)`
   satisfies identity of indiscernibles (`hDist_eq_zero_iff`), symmetry
   (`hDist_symm`), and the strong/ultrametric triangle inequality
   (`hDist_strong_triangle`), with the ordinary triangle inequality as a corollary.
   This is the "depth distance" `d(x,y) = p^(-(depth (x-y)))` of the concept brief.

2. **A categorical carrier over ℤ.** The prime-divisibility indicator
   `valInt p n = if (p:ℤ) ∣ n then 0 else 1` is a multiplicative ℕ-valued ultrametric
   seminorm (`valInt_mul`, `valInt_add`), so it assembles into a
   `TropicalValuationCarrier` (`arithDepthCarrier`) and, via the catalog functor
   `valuationReconstruct`, into an `UltraNormObj` whose norm is genuinely
   nonarchimedean (`arithDepthCarrier_ultrametric`). The representation theorem
   `valInt_eq_one_iff_residue` identifies this depth with the indicator of
   nonvanishing in the residue field `ZMod p` — a Gelfand-style "evaluation at the
   prime `p`".

The conceptual unifier is a **rigidity/duality obstruction**, `field_norm_rigid`:
on *any* field, a multiplicative ℕ-valued map sending `1 ↦ 1` is identically `1` on
nonzero elements. This explains a structural fork that the catalog interface forces
but never made explicit: quantitative depth cannot live in an ℕ-valued *multiplicative*
norm over a field, so it must be carried either by a real-valued absolute value (face 1)
or by a non-field carrier such as ℤ (face 2).

## Results Summary

- `hDist_nonneg`, `hDist_self`, `hDist_eq_zero_iff`, `hDist_symm`,
  `hDist_strong_triangle`, `hDist_triangle` — the depth metric on ℚ is an ultrametric.
- `valInt_zero`, `valInt_neg`, `valInt_mul`, `valInt_add` — the ℤ divisibility depth
  is a multiplicative ℕ-valued ultrametric seminorm.
- `valInt_eq_one_iff_residue` — residue-field representation of the depth.
- `arithDepthCarrier` + `arithDepthCarrier_ultrametric` — the bridge constructor into
  the catalog object layer.
- `field_norm_rigid` — the field-rigidity obstruction.

All main results are `sorry`-free and depend only on `propext`, `Classical.choice`,
and `Quot.sound`.

## Falsifiable Research Directions

### 1. Completeness of the depth metric and the p-adic integers as a limit object
The key insight is that `hDist p` is not merely an ultrametric but the restriction to ℚ
of the metric whose completion is `ℚ_p`, so the abstract `UltraNormObj` carrier should
admit a *completion functor* landing in a complete ultrametric object. Conjecture: the
Cauchy-sequence completion of `(ℚ, hDist p)` is isometric to Mathlib's `Padic p`, and
the `arithDepthCarrier` indicator descends to the closed unit ball `ℤ_p`. Why now: the
real-valued metric facts are already proved here and Mathlib already has `Padic`/`PadicInt`,
so the only missing piece is the isometry, which is directly testable (and falsifiable by
exhibiting a Cauchy sequence whose limits disagree).

### 2. Multiplicativity defect classifies the field/non-field boundary quantitatively
The key insight is that `field_norm_rigid` is the degenerate endpoint of a measurable
*multiplicativity defect* `f(ab) - f(a)f(b)`, and tracking this defect should yield a
sharp dichotomy. Conjecture: for a commutative ring `R`, every ℕ-valued multiplicative
ultrametric seminorm with `f 1 = 1` is the indicator of a prime ideal `𝔭`
(`f x = 0 ↔ x ∈ 𝔭`), and it is nonconstant on units iff `R` is not a field. Why now: we
have both the rigidity endpoint (`field_norm_rigid`) and a working non-field example
(`valInt`, whose kernel is `(p)`), so the general statement is a natural interpolation
that is falsifiable on any explicit non-domain (e.g. `ZMod 6`).

### 3. Functoriality of the arithmetic-height bridge across primes
The key insight is that varying the prime `p` should turn `arithDepthCarrier` into a
*diagram* of carriers connected by reduction maps, making the whole construction a functor
from primes to `UltraNormObj`. Conjecture: the family `{arithDepthCarrier p}` together with
the identity-on-ℤ maps forms a functor whose `valuationReconstruct`-image realizes the
product norm `∏_p valInt p` as the "trivial-away-from-S" seminorm for any finite prime set
`S`, recovering the S-integer height. Why now: the single-prime bridge and the catalog's
`UltraHom`/`tropicalization_map` morphism layer already exist, so functoriality is a
finite assembly task, falsifiable by checking the morphism axioms on two primes.

### 4. Strong triangle ⇒ certified-robustness radii in the catalog's ML layer
The key insight is that the ultrametric inequality makes balls *clopen and nested*, so the
depth metric should produce exact (not approximate) certified-robustness radii of the kind
the catalog's `QuantumCertifiedRadiusData`/`PostQuantumGapWitness` structures anticipate.
Conjecture: for the reconstructed object `valuationReconstruct (arithDepthCarrier p)`, every
point has a `PostQuantumGapWitness` with `gap = 1`, i.e. the divisibility depth separates
each p-adic unit from every non-unit by a hard gap. Why now: `arithDepthCarrier_ultrametric`
and the existing gap-witness structure are both in place, so the witness is a direct
construction, falsifiable by finding a point that violates the `gap_pos`/`security` clauses.

### 5. From depth seminorm to a genuine ultrametric *space* instance
The key insight is that `hDist` already satisfies all four axioms of an ultrametric, so it
should yield a bona fide `Mathlib`-level metric/`IsUltrametricDist` instance on a suitable
quotient, upgrading the catalog objects from "carriers of inequalities" to first-class
metric spaces. Conjecture: `hDist p` descends to a `MetricSpace` (in fact
`IsUltrametricDist`) structure on ℚ via Mathlib's `padicNorm`-induced absolute value, and
this instance is defeq-compatible with the `UltraNormObj` reconstruction. Why now: the four
axioms are proved here and Mathlib has `IsUltrametricDist`; the remaining work is wiring the
instance, falsifiable immediately if the triangle/zero axioms fail to line up with Mathlib's
`dist` conventions.
