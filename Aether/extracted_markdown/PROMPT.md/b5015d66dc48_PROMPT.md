
## PHASE B: PACKAGING ONLY — COMMUNICATING THE MATH

Phase A of this cycle has already done the math. Lean 4 files have
been produced with 3-5 world-class theorems. Your ONLY job in
Phase B is to **package this work for human readers**.

### DELIVERABLES (strict — only this):
1. **ARTICLE.md** — Standalone popular-science article (1500-3000 words).
   Write about IDEAS, not formal verification. No mentions of Lean or
   proof assistants. Vivid prose, narrative arc, real-world connections.
   **Must be fully self-contained and publishable without any external
   references.** State every theorem, result, and definition inline —
   do NOT use @file references or point to other files. A reader with
   only this article must understand every result without looking elsewhere.
2. **RESEARCH_PAPER.md** — In-depth research paper (3000-8000 words).
   Abstract, definitions, main results (with proof sketches — NOT
   full Lean), algorithms, applications, discussion, future work.
   **Must be fully self-contained and publishable quality without any
   external references.** State every theorem, lemma, and definition
   inline with its full mathematical statement and proof sketch. Do NOT
   use @file references or reference other files. A reader with only this
   paper must be able to follow every result from start to finish.
3. **demo.py** — Numerical examples demonstrating the key results.
   Self-contained Python, type hints, all functions inlined.
4. **PACKAGE.json** — Single JSON bundling all of the above, with this schema:

```json
{
  "title": "Human-Readable Package Title",
  "domain": "Algebra|Applications|Bridges|Computation|Cryptography|EML|Geometry|Logic|MachineLearning|Novelty|Physics|Pythagorean|Shared|Tropical",
  "description": "1-2 sentence description of the package",
  "authors": ["Author Name"],
  "date": "YYYY-MM-DD",
  "key_results": ["Key result 1", "Key result 2"],
  "keywords": ["keyword1", "keyword2"],
  "article": "ARTICLE.md",
  "research_paper": "RESEARCH_PAPER.md",
  "demo": "demo.py",
  "demos": [
    {"name": "Descriptive and Professional Title of the Python Demo", "description": "A comprehensive, high-quality description of what this Python demo calculates and shows mathematically.", "code": "# full Python source..."}
  ],
  "algorithms": [
    {
      "name": "Formal Mathematical Title of the Algorithm",
      "description": "Detailed in-depth explanation of the algorithm, its mathematical foundation, computational complexity, and role in the pipeline.",
      "pseudocode": "Formal, structured step-by-step pseudocode detailing the logic.",
      "code": "# full Python source with type hints..."
    }
  ],
  "visualizations": [
    {"name": "Descriptive Visualization Title", "description": "What this visualizes", "code": "# standalone Python script that generates a visualization..."}
  ],
  "interactive_demos": [
    {"title": "Beautiful Math-Rich Interactive Widget Title", "description": "Detailed description of the interactive widget and what users can explore.", "html": "<!DOCTYPE html><html>...</html>"}
  ],
  "lean_proofs": "LEAN_FILE_CONTENT_OR_PLACEHOLDER",
  "future_directions": "FUTURE_DIRECTIONS_CONTENT",
  "modules": {"demo": "# full demo.py source..."},
  "lean_files": ["Catalog/Domain/Package/File.lean"]
}
```

**CRITICAL**: The `demos`, `algorithms`, `visualizations`, and
`interactive_demos` fields MUST be arrays of objects with the
exact structure shown above. Do NOT use placeholder strings like
"MISSING" — either include real content or omit the field entirely.

### DO NOT OUTPUT:
- NO new `.lean` files
- NO new theorem proofs
- NO changes to the existing Lean 4 source
- NO `FUTURE_DIRECTIONS.md` as a separate file (Phase A already produced
  future directions — they are provided below for inclusion in PACKAGE.json)

The math is already proved. Treat the Lean files below as the
ground truth — your prose should explain and contextualize them.
State theorems inline in your article and paper — they must be
self-contained and publishable without external references.


## Concept

**Title**: Deepening: This cycle isolated the *entry point* (rank of apparition) `z(p) = ` least `k > 
**Domain**: Applications
**Mathematical framing**: Building on cycle 80ea5c05 (Q=0.778), which proved 10 theorems in Applications. Go DEEPER: prove the strongest remaining conjecture, close open sorries, or extend the core result to a more general setting. Original direction: # Future Directions — Fibonacci Entry Points and Carmichael's Theorem

## Synthesis

This cycle isolated the *entry point* (rank of apparition) `z(p) = ` least `k > 0`
with `p ∣ F(k)` as the single organizing object behind the catalog's scattered
Carmichael/primitive-divisor reasoning. The new file

Research domain: Applications
Research mode: team


## Phase A Lean 4 Output (the math — read this carefully)

```
-- NEW_FILE: Catalog/Novelty/FibonacciPisanoRepresentation.lean
import Mathlib

/-!
# The Pisano period as the order of the Fibonacci shift: a representation/duality view

For a modulus `m ≥ 1` the **Pisano period** `π(m)` is the period of the Fibonacci
sequence taken modulo `m`.  This file isolates `π(m)` as a *representation-theoretic*
object: it is exactly the **order of a single group element**, the Fibonacci shift

`Q : (a, b) ↦ (b, a + b)`

viewed as a permutation of the finite set `ZMod m × ZMod m`.  Under this dictionary the
*dynamics* of the Fibonacci recurrence becomes the *algebra* of a cyclic subgroup of
`Equiv.Perm (ZMod m × ZMod m)`, and several facts that look analytic (periodicity) or
combinatorial become one-line consequences of `orderOf` theory.

This is the duality/representation companion to the catalog's *entry-point* (rank of
apparition) theory:

* `FibApparition` (`Catalog/Novelty/FibApparitionExistence.lean`) builds the entry point
  `z(m)` — least `k > 0` with `m ∣ F k` — and the ideal law `m ∣ F n ↔ z(m) ∣ n`.
* `FibEntryChar` (`Catalog/Speculative/AutoResearch/CarmichaelComposite.lean`,
  `Catalog/Novelty/FibonacciEntryPointMultiplicative.lean`) develops the multiplicative
  lcm-algebra of the entry point.

The new organizing object here is `pisanoPeriod m := orderOf (fibStep m)`.  Its relation
to the entry point is `dvd_fib_pisanoPeriod` (`m ∣ F(π m)`, hence `z(m) ∣ π(m)` via the
catalog law `FibApparition.fib_dvd_iff_apparitionRank_dvd`), and the
crowning result `pisano_mul_coprime` is the **Chinese-Remainder/spectral
decomposition** `π(mn) = lcm(π m, π n)` for coprime moduli — the product dynamical
system factors as a product of its prime-power "spectral" components, exactly mirroring
the entry point's lcm law `FibEntryChar.fibEntryPt_prod_coprime`.

-- !-- Lab Notebook -- !--
-- !-- Hypothesis: the Pisano period is not merely "the period of a sequence" but the
--     order of the shift automorphism Q in Perm(ZMod m × ZMod m); hence periodicity,
--     the entry-point bound, and CRT-multiplicativity should all follow from generic
--     `orderOf` machinery plus the closed iterate formula for Q^k. -- !--
-- !-- Result: proved the closed form Q^[k](a,b) = (a F(k-1)+b F k, a F k + b F(k+1)),
--     the divisibility duality π(m) ∣ k ↔ (F k ≡ 0 ∧ F(k+1) ≡ 1) (mod m), periodicity,
--     z(m) ∣ π(m), and π(mn) = lcm(π m, π n) for coprime m, n. -- !--
-- !-- Insight: ALL Fibonacci content is concentrated in one induction (the iterate
--     formula `fibStep_iterate_apply`); after that the period is pure group theory, and
--     CRT-multiplicativity is just `Nat.Coprime.mul_dvd` distributed across a `dvd`-iff. -- !--
-- !-- Failure analysis: the only friction is bookkeeping the `ZMod` ↔ `ℕ` casts for the
--     condition `F(k+1) ≡ 1`; phrasing the CRT step through `Nat` divisibility of
--     `F k` and `F(k+1) - 1` (using `1 ≤ F(k+1)`) removes it entirely. -- !--
-- !-- End Lab Notebook -- !--
-/

namespace FibPisano

open scoped Classical

/-- The Fibonacci **shift** automorphism on `ZMod m × ZMod m`, `(a, b) ↦ (b, a + b)`,
with inverse `(a, b) ↦ (b - a, a)`.  Iterating it from `(0, 1)` reads off consecutive
Fibonacci numbers, so the entire Fibonacci sequence mod `m` is the orbit of this single
group element. -/
def fibStep (m : ℕ) : Equiv.Perm (ZMod m × ZMod m) where
  toFun p := (p.2, p.1 + p.2)
  invFun p := (p.2 - p.1, p.1)
  left_inv := by intro p; simp
  right_inv := by intro p; simp [add_comm]

/-- The **Pisano period** of `m`: the order of the Fibonacci shift in the (finite for
`m ≥ 1`) permutation group of `ZMod m × ZMod m`. -/
noncomputable def pisanoPeriod (m : ℕ) : ℕ := orderOf (fibStep m)

/-
!-- Closed form for the k-th iterate of the shift, by induction on k using
`Function.iterate_succ_apply'` and `Nat.fib_add_two`; this is the only step that
touches the Fibonacci recurrence. -- !--

Closed form: the `k`-th power of the shift is the Fibonacci `Q^k` matrix acting on
`(a, b)`.
-/
theorem fibStep_iterate_apply (m k : ℕ) (a b : ZMod m) :
    (⇑(fibStep m))^[k] (a, b) =
      (a * ((Nat.fib (k + 1) : ZMod m) - (Nat.fib k : ZMod m)) + b * (Nat.fib k : ZMod m),
       a * (Nat.fib k : ZMod m) + b * (Nat.fib (k + 1) : ZMod m)) := by
  induction' k with k ih generalizing a b
  · simp
  · rw [Function.iterate_succ_apply', ih]
    simp only [fibStep, Equiv.coe_fn_mk, Nat.fib_add_two]
    push_cast
    rw [Prod.mk.injEq]
    exact ⟨by ring, by ring⟩

/-
!-- Representation theorem: specialize the closed form at (a,b) = (0,1). -- !--

**Representation of the Fibonacci sequence as a group orbit.** Iterating the shift
from `(0, 1)` yields consecutive Fibonacci numbers mod `m`.
-/
theorem fibStep_iterate (m k : ℕ) :
    (⇑(fibStep m))^[k] (0, 1) = ((Nat.fib k : ZMod m), (Nat.fib (k + 1) : ZMod m)) := by
  induction k <;> simp_all +decide [ Function.iterate_succ_apply', Nat.fib_add_two ];
  rfl

/-
For `m ≥ 1` the shift has positive (finite) order: the Pisano period exists.
-/
theorem pisanoPeriod_pos (m : ℕ) [NeZero m] : 0 < pisanoPeriod m := by
  convert Nat.pos_of_ne_zero _;
  -- Since `fibStep m` is a permutation of a finite set, it must have finite order.
  have h_finite_order : ∃ k > 0, (fibStep m) ^ k = 1 := by
    exact ⟨ orderOf ( fibStep m ), orderOf_pos _, pow_orderOf_eq_one _ ⟩;
  exact Nat.ne_of_gt ( Nat.pos_of_dvd_of_pos ( orderOf_dvd_iff_pow_eq_one.mpr h_finite_order.choose_spec.2 ) h_finite_order.choose_spec.1 )

/-
!-- The power Q^k is the identity permutation iff it fixes (0,1) (forward: apply at
(0,1) via `fibStep_iterate`; backward: the closed form with F k = 0, F(k+1) = 1
collapses to the identity, then `Equiv.Perm.ext`). -- !--

The shift power `Q^k` is trivial iff the sequence has returned to its seed:
`F k ≡ 0` and `F(k+1) ≡ 1` (mod `m`).
-/
theorem fibStep_pow_eq_one_iff (m k : ℕ) :
    (fibStep m) ^ k = 1 ↔
      ((Nat.fib k : ZMod m) = 0 ∧ (Nat.fib (k + 1) : ZMod m) = 1) := by
  constructor;
  · intro h
    have h_fib : (fibStep m)^[k] (0, 1) = (0, 1) := by
      convert congr_arg ( fun f : Equiv.Perm ( ZMod m × ZMod m ) => f ( 0, 1 ) ) h using 1;
    rw [ fibStep_iterate ] at h_fib ; aesop;
  · intro h;
    ext ⟨ a, b ⟩;
    · convert fibStep_iterate_apply m k a b |> congr_arg Prod.fst using 1;
      aesop;
    · convert congr_arg Prod.snd ( fibStep_iterate_apply m k a b ) using 1 ; aesop

/-
!-- Combine `orderOf_dvd_iff_pow_eq_one` with `fibStep_pow_eq_one_iff`. -- !--

**Period–return duality.** The Pisano period divides `k` exactly when the Fibonacci
sequence mod `m` has returned to its initial value at index `k`.
-/
theorem pisano_dvd_iff (m k : ℕ) :
    pisanoPeriod m ∣ k ↔
      ((Nat.fib k : ZMod m) = 0 ∧ (Nat.fib (k + 1) : ZMod m) = 1) := by
  rw [ ← fibStep_pow_eq_one_iff ];
  convert orderOf_dvd_iff_pow_eq_one using 1

/-
!-- Use the orbit description: Q^[n+π](0,1) = Q^[π](Q^[n](0,1)) = Q^[n](0,1) since
Q^π = 1; read off the first coordinate. -- !--

**Periodicity.** The Fibonacci sequence mod `m` is periodic with period `π(m)`.
-/
theorem fib_pisano_periodic (m n : ℕ) :
    (Nat.fib (n + pisanoPeriod m) : ZMod m) = (Nat.fib n : ZMod m) := by
  convert congr_arg Prod.fst ( fibStep_iterate m n ) using 1;
  convert congr_arg Prod.fst ( fibStep_iterate m ( n + orderOf ( fibStep m ) ) ) using 1;
  · rw [ fibStep_iterate ];
    rfl;
  · convert congr_arg Prod.fst ( fibStep_iterate m ( n + orderOf ( fibStep m ) ) ) using 1;
    simp +decide [ pow_add, pow_orderOf_eq_one ]

/-
!-- π(m) divides itself, so `pisano_dvd_iff` gives F(π m) ≡ 0 (mod m), i.e. m ∣ F(π m);
thus π(m) is an apparition index and the entry point z(m) divides it. -- !--

The Pisano period is an apparition index: `m ∣ F(π m)`.  Hence (via the catalog law
`FibApparition.fib_dvd_iff_apparitionRank_dvd`) the entry point `z(m)` divides `π(m)`.
-/
theorem dvd_fib_pisanoPeriod (m : ℕ) : m ∣ Nat.fib (pisanoPeriod m) := by
  by_contra h_contra;
  apply_mod_cast h_contra <| by have := pisano_dvd_iff m ( pisanoPeriod m ) |>.1 ( dvd_refl _ 
```

## Phase A Future Directions (include in PACKAGE.json)

Phase A produced these future research directions. Include them verbatim
(or lightly edited for clarity) in the `future_directions` field of
PACKAGE.json so they appear in the "Future Directions" tab on the website.

```
# Future Directions — The Pisano Period as a Group Order (Duality & Representation)

## Synthesis

This cycle re-cast the **Pisano period** `π(m)` — the period of the Fibonacci
sequence modulo `m` — not as an analytic property of a sequence but as the
**order of a single group element**: the Fibonacci shift `Q : (a,b) ↦ (b, a+b)`
acting as a permutation of the finite set `ZMod m × ZMod m`. The new file
`Catalog/Novelty/FibonacciPisanoRepresentation.lean` makes this dictionary precise:

* `fibStep_iterate` — the Fibonacci sequence mod `m` *is* the forward orbit of `(0,1)`
  under `Q` (the representation theorem). The closed form `fibStep_iterate_apply`
  exhibits `Qᵏ` as the classical Fibonacci `Q`-matrix `[[F(k-1),F k],[F k,F(k+1)]]`.
* `pisanoPeriod m := orderOf (fibStep m)`, with `pisanoPeriod_pos` (existence) a one-line
  consequence of finiteness of the permutation group.
* `pisano_dvd_iff` — the **period–return duality**: `π(m) ∣ k ↔ (F k ≡ 0 ∧ F(k+1) ≡ 1) mod m`.
  Algebraic divisibility on one side, dynamical "return to seed" on the other.
* `fib_pisano_periodic` — periodicity, derived purely from `Qᵖ = 1`.
* `dvd_fib_pisanoPeriod` — `m ∣ F(π m)`, so `π(m)` is an apparition index; combined with the
  catalog law `FibApparition.fib_dvd_iff_apparitionRank_dvd` this yields `z(m) ∣ π(m)`,
  bridging this file to the entry-point theory.
* `pisano_mul_coprime` — the **Chinese-Remainder / spectral decomposition**
  `π(mn) = lcm(π m, π n)` for coprime `m, n`: the product dynamical system factors as a
  product of components, mirroring the entry point's lcm law
  `FibEntryChar.fibEntryPt_prod_coprime`.

The unifying message: the *entry point* `z(m)` is the order of `Q` acting on the cyclic
*line* through `(0,1)`, while the *Pisano period* `π(m)` is the order of `Q` on the whole
*plane* `(ZMod m)²`. Both are orders of one representation; their lcm-multiplicativity is
the same CRT fact applied to two orbits.

## Results Summary

All theorems are proved with no `sorry` and depend only on the standard axioms
(`propext`, `Classical.choice`, `Quot.sound`). The Fibonacci-specific content is fully
localized in one induction (`fibStep_iterate_apply`); every period statement afterwards is
generic `orderOf` algebra plus elementary `ℕ` divisibility.

## Research Directions

### 1. The exact entry-point / Pisano ratio `π(m) / z(m) ∈ {1, 2, 4}`

We proved `z(m) ∣ π(m)`. The classical theory asserts the quotient `π(m)/z(m)` is always
**1, 2, or 4** (it equals the multiplicative order of `(-1)^{z(m)} F(z(m)-1)` etc.).
**The key insight is** that `Qᵏ = 1` forces `F k ≡ 0, F(k+1) ≡ 1`, whereas `Q` killing the
*line* `(0,1)` only forces `F k ≡ 0`; the obstruction is exactly the scalar `Q^{z}` acts by
on that line, an element of `(ZMod m)ˣ` whose order is the ratio. So the ratio is the order
of a single unit — bounded once one shows `(Q^{z})² ` or `(Q^z)⁴` is scalar `1`.
**Why now?** The closed-form `fibStep_iterate_apply` already expresses `Q^z` as an explicit
matrix
```

## Your task

Produce the deliverables listed above. The Lean file is the source of truth —
your prose must accurately explain it. Both ARTICLE.md and RESEARCH_PAPER.md
MUST be self-contained and publishable without referencing any external files.
State every theorem, definition, and result inline so a reader can follow the
entire argument from the document alone.

ARTICLE.md: write a popular-science narrative that makes the key idea accessible.
RESEARCH_PAPER.md: write the formal paper with abstract, definitions, results.
demo.py: write numerical examples that demonstrate the results.
PACKAGE.json: bundle everything into a single JSON with ALL fields populated.
Make sure demos, algorithms, visualizations, and interactive_demos are arrays
of objects (not placeholder strings). For each algorithm in the algorithms array, provide a clear, professional mathematical title in 'name' (do not use generic placeholders; this will be displayed as the header on the interactive site), a detailed explanation of its logic and complexity in 'description', formal step-by-step pseudocode in 'pseudocode', and clean type-hinted Python code in 'code'. For each Python demo in the demos array, provide a highly descriptive title in 'name', a comprehensive functional description in 'description', and the implementation code in 'code'. For each interactive HTML demo in interactive_demos, provide a beautiful title in 'title' and a detailed description in 'description'. Include future directions from Phase A in the future_directions field.

Be vivid, be precise, be world-class. The math has already been done — now
make it beautiful to read.
