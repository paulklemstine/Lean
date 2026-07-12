import Novelty.CircuitComplexity.Basic

/-!
# The approximation method for monotone circuit lower bounds

Razborov's *approximation method* proves size lower bounds by replacing each gate
of a circuit with an *approximate* gate drawn from a restricted family, while
controlling the number of inputs on which each replacement introduces an error.
The two pillars of the technique are:

1. *each gate introduces few errors* (locally accurate approximators), and
2. *the global approximator is far from the target function* (the family is too
   coarse to compute the function).

Combining the two, the number of gates — hence the size — must be large.

Here we formalize the abstract, function-agnostic *core* of the method, which is
exactly the union-bound / error-accumulation argument:

* `approxEval` — evaluate a circuit with an arbitrary *rounding* operator `R`
  applied at every AND/OR gate;
* `numGates` — the number of internal (AND/OR) gates, with `numGates_le_size`;
* `approx_error_bound` — **error accumulation**: if every single rounding step
  errs on at most `δ` of the test inputs `T`, then the fully-rounded circuit errs
  on at most `numGates · δ` of them;
* `approx_method_size_lb` — the **size lower bound**: if, in addition, the rounded
  circuit is *far* (disagrees on at least `E` test inputs) from the true circuit,
  then `E ≤ size · δ`, i.e. `size ≥ E / δ`.

The last theorem is precisely the inequality that the full Razborov argument feeds
its two combinatorial estimates into; instantiating `R`, `δ` and `E` for the
sunflower-based clique approximators yields the exponential bound (the deep step,
documented in `FUTURE_DIRECTIONS.md`).

-- !-- Lab Notes -- !--
HYPOTHESIS (Hypothesizer): the approximation method factors into a purely
structural error-accumulation inequality (`total error ≤ #gates × per-gate
error`) plus two problem-specific estimates.  The structural part should be
provable by a clean induction independent of CLIQUE.

EXPERIMENT (Experimenter): model rounding as an arbitrary operator `R` on Boolean
functions applied at every gate (`approxEval`), measure error against a finite
test set `T`, and prove the accumulation bound by structural induction using a
three-way union bound at each gate.

ANALYSIS (Analyst): the inductive step is a subset argument — an input on which
the rounded circuit disagrees with the real circuit must witness a disagreement
in the left child, the right child, or the local rounding step; `Finset.card_union_le`
then sums the three contributions.  The constants line up exactly:
`numGates (a ∧ b) = numGates a + numGates b + 1`.

CRITIQUE (Critic): `R` is completely arbitrary, so `approx_error_bound` is not
vacuous and the per-gate hypothesis `hδ` is a genuine quantitative constraint.
`approx_method_size_lb` is a real (conditional) size lower bound: its two
hypotheses are independent and jointly satisfiable, and the conclusion constrains
`size`.  We do *not* claim the exponential CLIQUE bound — only the abstract engine
that derives it from its two inputs.

SYNTHESIS (PI): this places the approximation method on the same formal footing as
the relevant-variable bound (`Basic`) and the Karchmer–Wigderson depth bound
(`KarchmerWigderson`), completing a three-pronged formal toolkit for monotone
circuit lower bounds.
-/

namespace CircuitComplexity
namespace MCircuit

variable {ι : Type*}

/-- The number of internal (AND/OR) gates of a circuit. -/
def numGates : MCircuit ι → ℕ
  | var _ => 0
  | top => 0
  | bot => 0
  | and a b => numGates a + numGates b + 1
  | or a b => numGates a + numGates b + 1

@[simp] theorem numGates_var (i : ι) : (var i).numGates = 0 := rfl
@[simp] theorem numGates_top : (top : MCircuit ι).numGates = 0 := rfl
@[simp] theorem numGates_bot : (bot : MCircuit ι).numGates = 0 := rfl
@[simp] theorem numGates_and (a b : MCircuit ι) :
    (and a b).numGates = a.numGates + b.numGates + 1 := rfl
@[simp] theorem numGates_or (a b : MCircuit ι) :
    (or a b).numGates = a.numGates + b.numGates + 1 := rfl

/-- The number of gates is at most the size of the circuit. -/
theorem numGates_le_size (C : MCircuit ι) : C.numGates ≤ C.size := by
  induction C with
  | var i => simp [numGates, size]
  | top => simp [numGates, size]
  | bot => simp [numGates, size]
  | and a b iha ihb => simp only [numGates, size]; omega
  | or a b iha ihb => simp only [numGates, size]; omega

/-- Approximate evaluation: identical to `eval` on variables and constants, but a
*rounding operator* `R` is applied to the result of every AND/OR gate.  Taking
`R = id` recovers the exact `eval`. -/
def approxEval (R : ((ι → Bool) → Bool) → ((ι → Bool) → Bool)) :
    MCircuit ι → (ι → Bool) → Bool
  | var i, x => x i
  | top, _ => true
  | bot, _ => false
  | and a b, x => R (fun z => approxEval R a z && approxEval R b z) x
  | or a b, x => R (fun z => approxEval R a z || approxEval R b z) x

@[simp] theorem approxEval_var (R) (i : ι) (x : ι → Bool) :
    approxEval R (var i) x = x i := rfl
@[simp] theorem approxEval_top (R) (x : ι → Bool) :
    approxEval R (top : MCircuit ι) x = true := rfl
@[simp] theorem approxEval_bot (R) (x : ι → Bool) :
    approxEval R (bot : MCircuit ι) x = false := rfl
@[simp] theorem approxEval_and (R) (a b : MCircuit ι) (x : ι → Bool) :
    approxEval R (and a b) x = R (fun z => approxEval R a z && approxEval R b z) x := rfl
@[simp] theorem approxEval_or (R) (a b : MCircuit ι) (x : ι → Bool) :
    approxEval R (or a b) x = R (fun z => approxEval R a z || approxEval R b z) x := rfl

/-
**Error accumulation (core of the approximation method).**  Let `R` be any
rounding operator and `T` a finite set of test inputs.  If every single rounding
step disagrees with its un-rounded argument on at most `δ` of the test inputs,
then the fully rounded circuit disagrees with the true circuit on at most
`numGates · δ` of them.
-/
theorem approx_error_bound
    (R : ((ι → Bool) → Bool) → ((ι → Bool) → Bool))
    (T : Finset (ι → Bool)) (δ : ℕ)
    (hδ : ∀ g : (ι → Bool) → Bool, (T.filter (fun x => R g x ≠ g x)).card ≤ δ)
    (C : MCircuit ι) :
    (T.filter (fun x => C.eval x ≠ approxEval R C x)).card ≤ C.numGates * δ := by
  induction' C with i a b ih_a ih_b generalizing T <;> simp_all +decide;
  · -- Apply the union bound to the three sets.
    have h_union_bound : (T.filter (fun x => ¬(a.eval x && b.eval x) = R (fun z => approxEval R a z && approxEval R b z) x)).card ≤
      (T.filter (fun x => ¬a.eval x = approxEval R a x)).card +
      (T.filter (fun x => ¬b.eval x = approxEval R b x)).card +
      (T.filter (fun x => ¬R (fun z => approxEval R a z && approxEval R b z) x = (approxEval R a x && approxEval R b x))).card := by
        rw [ Finset.card_filter, Finset.card_filter, Finset.card_filter, Finset.card_filter ];
        rw [ ← Finset.sum_add_distrib, ← Finset.sum_add_distrib ];
        gcongr ; aesop;
    linarith [ ih_a T hδ, ih_b T hδ, hδ ( fun z => approxEval R a z && approxEval R b z ) ];
  · rename_i a b ha hb;
    -- Let's simplify the goal using the fact that multiplication by a constant out of the set does not change the cardinality.
    suffices h_simp : (Finset.filter (fun x => ¬(a.eval x || b.eval x) = R (fun z => approxEval R a z || approxEval R b z) x) T).card ≤ (Finset.filter (fun x => ¬a.eval x = approxEval R a x) T).card + (Finset.filter (fun x => ¬b.eval x = approxEval R b x) T).card + (Finset.filter (fun x => ¬R (fun z => approxEval R a z || approxEval R b z) x = (approxEval R a x || approxEval R b x)) T).card by
      linarith [ ha T hδ, hb T hδ, hδ ( fun z => approxEval R a z || approxEval R b z ) ];
    rw [ Finset.card_filter, Finset.card_filter, Finset.card_filter, Finset.card_filter ];
    rw [ ← Finset.sum_add_distrib, ← Finset.sum_add_distrib ];
    gcongr ; simp_all +decide [ eq_comm ];
    grind

/-
**The approximation-method size lower bound.**  If, on top of the per-gate
accuracy hypothesis `hδ`, the rounded circuit is *far* from the true circuit —
disagreeing on at least `E` of the test inputs — then `E ≤ size · δ`.  Equivalently
`size ≥ E / δ`: a circuit whose every gate is locally accurate yet whose overall
behaviour is globally far from the truth must be large.
-/
theorem approx_method_size_lb
    (R : ((ι → Bool) → Bool) → ((ι → Bool) → Bool))
    (T : Finset (ι → Bool)) (δ E : ℕ)
    (hδ : ∀ g : (ι → Bool) → Bool, (T.filter (fun x => R g x ≠ g x)).card ≤ δ)
    (C : MCircuit ι)
    (hfar : E ≤ (T.filter (fun x => C.eval x ≠ approxEval R C x)).card) :
    E ≤ C.size * δ := by
  refine' le_trans hfar ( le_trans ( _ : _ ≤ C.numGates * δ ) ( Nat.mul_le_mul_right δ ( numGates_le_size C ) ) );
  convert approx_error_bound R T δ hδ C using 1

end MCircuit
end CircuitComplexity