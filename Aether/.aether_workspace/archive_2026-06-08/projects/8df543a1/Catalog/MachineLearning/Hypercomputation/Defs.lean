import Mathlib

/-!
# Hypercomputation: Foundations and Physical Constraints

We formalize a rigorous framework for studying hypercomputation — computation that
transcends the Church-Turing barrier. Our main contributions:

1. **Computability Model**: An axiomatic framework capturing essential properties
   of Turing-computable functions via enumeration
2. **Diagonal Undecidability**: The anti-diagonal of any enumeration escapes it
3. **Oracle Power Hierarchy**: Strict separation between oracle levels
4. **Physical Constraint Theorems**: Convergence to non-computable oracles requires
   unbounded resources
5. **Accidentally vs. Essentially Computable**: Formal separation

## Key Mathematical Insight

The central result is that any finite-precision physical device can be modeled as
a single computable function, so it cannot solve problems outside the computable class.
A hypercomputer that converges to a non-computable oracle must therefore use
unboundedly many "stages" (energy levels, precision doublings, etc.).
-/

noncomputable section
open Set Function Classical

/-! ## Part 1: The Cantor Diagonal for Boolean Functions -/

/-- **Cantor Diagonal for Bool**: The anti-diagonal of any two-argument Boolean
    function cannot appear as any row. This is the combinatorial core of all
    undecidability results. -/
theorem cantor_diagonal_bool (f : ℕ → ℕ → Bool) :
    ¬ ∃ k : ℕ, ∀ n : ℕ, f k n = !f n n := by
  rintro ⟨k, hk⟩
  specialize hk k
  cases h : f k k <;> simp_all

/-! ## Part 2: Axiomatic Computability Model -/

/-- A `ComputabilityModel` axiomatizes the essential properties of Turing computability.
    It provides a countable class of "computable" Boolean functions, enumerated by
    natural numbers, such that the class is closed under basic operations but the
    anti-diagonal escapes it. -/
structure ComputabilityModel where
  /-- The enumeration of all computable functions ℕ → Bool -/
  φ : ℕ → ℕ → Bool
  /-- The class is closed under Boolean negation at each argument -/
  neg_closed : ∀ e, ∃ e', ∀ n, φ e' n = !φ e n
  /-- The class is closed under constant functions -/
  const_closed : ∀ b : Bool, ∃ e, ∀ n, φ e n = b

/-- The anti-diagonal function of a computability model: `diag(n) = ¬φ(n,n)`. -/
def ComputabilityModel.antidiag (M : ComputabilityModel) : ℕ → Bool :=
  fun n => !M.φ n n

/-- **Fundamental Theorem of Computability**: The anti-diagonal function of any
    computability model is not in the enumeration. This is the halting problem
    in abstract form. -/
theorem antidiag_not_computable (M : ComputabilityModel) :
    ¬ ∃ e, ∀ n, M.φ e n = M.antidiag n :=
  cantor_diagonal_bool M.φ

/-- **Halting Problem Corollary**: The anti-diagonal differs from every computable
    function on at least one input. For any proposed index `e`, we can exhibit
    a concrete witness `e` itself where they disagree. -/
theorem halting_witness (M : ComputabilityModel) (e : ℕ) :
    M.φ e e ≠ M.antidiag e := by
  simp [ComputabilityModel.antidiag]

/-! ## Part 3: Oracle Hierarchy -/

/-- An oracle extends a computability model by adding access to a new function. -/
structure OracleExtension (M : ComputabilityModel) where
  /-- The extended enumeration -/
  φ' : ℕ → ℕ → Bool
  /-- Every old computable function is still computable -/
  extends_base : ∀ e, ∃ e', ∀ n, φ' e' n = M.φ e n
  /-- The anti-diagonal of M is now computable -/
  diag_computable : ∃ e, ∀ n, φ' e n = M.antidiag n

/-- An `OracleChainData` provides an infinite sequence of oracle extensions,
    each strictly more powerful than the last. -/
structure OracleChainData where
  /-- The model at each level -/
  level : ℕ → ComputabilityModel
  /-- Each level extends the previous -/
  extension : ∀ k, OracleExtension (level k)
  /-- The extended enumeration matches the next level -/
  coherent : ∀ k, (extension k).φ' = (level (k + 1)).φ

/-
**Strict Hierarchy Theorem**: At each level, the anti-diagonal of that level
    is computable at the next level but not at the current level.
-/
theorem strict_hierarchy (C : OracleChainData) (k : ℕ) :
    (¬ ∃ e, ∀ n, (C.level k).φ e n = (C.level k).antidiag n) ∧
    (∃ e, ∀ n, (C.level (k + 1)).φ e n = (C.level k).antidiag n) := by
  refine ⟨ antidiag_not_computable _, ?_ ⟩;
  convert C.extension k |>.diag_computable;
  exact C.coherent k ▸ rfl

/-- **No Level Collapses**: The anti-diagonal at level k cannot be computed at level k.
    (This is a direct consequence of the Cantor diagonal.) -/
theorem no_level_collapse (C : OracleChainData) (k : ℕ) :
    ¬ ∃ e, ∀ n, (C.level k).φ e n = (C.level k).antidiag n :=
  antidiag_not_computable (C.level k)

/-! ## Part 4: Physical Hypercomputation Constraints -/

/-- A `ConvergentApproximation` models a physical system that attempts to compute
    a target function by producing increasingly accurate approximations. -/
structure ConvergentApproximation where
  /-- The target (potentially non-computable) function -/
  target : ℕ → Bool
  /-- The sequence of approximations -/
  stage : ℕ → ℕ → Bool
  /-- Convergence: for each input, eventually the approximation stabilizes correctly -/
  converges : ∀ n, ∃ K, ∀ k, K ≤ k → stage k n = target n

/-
**Unbounded Convergence Time**: If the target is not computable in model M,
    and each stage IS computable, then every stage makes at least one error.
    No finite stage suffices — convergence requires passing through infinitely
    many stages.
-/
theorem unbounded_convergence_time (M : ComputabilityModel)
    (A : ConvergentApproximation)
    (h_noncomp : ¬ ∃ e, ∀ n, M.φ e n = A.target n)
    (h_stages_computable : ∀ k, ∃ e, ∀ n, M.φ e n = A.stage k n) :
    ∀ k : ℕ, ∃ n : ℕ, A.stage k n ≠ A.target n := by
  intro k
  by_contra h_contra
  push_neg at h_contra;
  exact h_noncomp <| by obtain ⟨ e, he ⟩ := h_stages_computable k; exact ⟨ e, fun n => by rw [ he, h_contra ] ⟩ ;

/-
**Single-Stage Insufficiency**: No single computable stage can equal a
    non-computable target.
-/
theorem single_stage_insufficient (M : ComputabilityModel)
    (target : ℕ → Bool)
    (h_noncomp : ¬ ∃ e, ∀ n, M.φ e n = target n)
    (e : ℕ) :
    ∃ n, M.φ e n ≠ target n := by
  exact not_forall.mp fun h => h_noncomp ⟨ e, h ⟩

/-- **Finite Resources Theorem**: Any physical device with finite state
    (representable by a computable function) cannot solve the halting problem
    for the computability model it belongs to. -/
theorem finite_resources_insufficient (M : ComputabilityModel) (e : ℕ) :
    ∃ n, M.φ e n ≠ M.antidiag n := by
  exact ⟨e, halting_witness M e⟩

/-! ## Part 5: Accidentally vs. Essentially Computable -/

/-- A function is `Computable` in model M if it appears in the enumeration. -/
def IsComputable (M : ComputabilityModel) (f : ℕ → Bool) : Prop :=
  ∃ e, ∀ n, M.φ e n = f n

/-- A function is `AccidentallyCorrect` on a finite set S if some computable
    function agrees with it on S. -/
def AccidentallyCorrect (M : ComputabilityModel) (f : ℕ → Bool) (S : Finset ℕ) : Prop :=
  ∃ e, ∀ n ∈ S, M.φ e n = f n

/-
**Every function is accidentally correct on the empty set.**
-/
theorem accidentally_correct_empty (M : ComputabilityModel) (f : ℕ → Bool) :
    AccidentallyCorrect M f ∅ := by
  exact ⟨ 0, by simp +decide ⟩

/-
**Accidental Correctness is Monotone**: Correctness on a larger set implies
    correctness on subsets.
-/
theorem accidentally_correct_mono (M : ComputabilityModel) (f : ℕ → Bool)
    (S T : Finset ℕ) (hST : T ⊆ S) (h : AccidentallyCorrect M f S) :
    AccidentallyCorrect M f T := by
  exact ⟨ h.choose, fun n hn => h.choose_spec n ( hST hn ) ⟩

/-
**Essential-Accidental Gap**: The anti-diagonal is accidentally correct on every
    singleton but not essentially computable.
-/
theorem essential_accidental_gap (M : ComputabilityModel) :
    (∀ n : ℕ, AccidentallyCorrect M M.antidiag {n}) ∧
    ¬ IsComputable M M.antidiag := by
  constructor;
  · intro n
    unfold AccidentallyCorrect
    obtain ⟨e', he'⟩ := M.neg_closed n
    use e'
    simp [he'];
    unfold ComputabilityModel.antidiag; aesop;
  · -- Apply the theorem that states the anti-diagonal function is not computable.
    apply antidiag_not_computable

/-! ## Part 6: Information-Theoretic Bounds -/

/-- **Oracle Information Content**: The number of distinct Boolean functions on
    a finite domain of size n is 2^n. -/
theorem oracle_info_content (n : ℕ) :
    Fintype.card (Fin n → Bool) = 2 ^ n := by
  simp [Fintype.card_bool, Fintype.card_fin]

/-- **No Free Lunch for Oracles**: For any fixed computable function and N ≥ 2,
    there exists a target that the function gets wrong within the first N inputs. -/
theorem no_free_lunch (proc : ℕ → Bool) (N : ℕ) (hN : 2 ≤ N) :
    ∃ target : ℕ → Bool, ∃ n, n < N ∧ proc n ≠ target n := by
  exact ⟨fun n => if n = 0 then !proc 0 else false,
         0, by omega, by cases proc 0 <;> simp⟩

/-
**Counting Argument**: Among all 2^N Boolean functions on {0,...,N-1},
    at most one can be fully matched by a given procedure on that domain.
    Therefore, any single procedure "misses" 2^N - 1 targets.
-/
theorem counting_argument (N : ℕ) (proc : Fin N → Bool) :
    Fintype.card {f : Fin N → Bool | f ≠ proc} = 2 ^ N - 1 := by
  simp +decide [Finset.card_univ]

/-! ## Part 7: Hierarchy Non-Collapse -/

/-
**Tower theorem**: In an oracle chain, level k's anti-diagonal is not computable
    at any level j ≤ k.
-/
theorem tower_noncomputable (C : OracleChainData) :
    ∀ k j, j ≤ k →
    ¬ ∃ e, ∀ n, (C.level j).φ e n = (C.level k).antidiag n := by
  intro k j hj;
  -- By induction on $k - j$, we can show that the anti-diagonal of level $k$ is not computable at level $j$.
  induction' h : k - j with m ih generalizing j k;
  · simp_all +decide [ Nat.sub_eq_iff_eq_add hj ];
    exact fun e => ⟨ e, by simp +decide [ ComputabilityModel.antidiag ] ⟩;
  · -- By the induction hypothesis, the anti-diagonal of level $k$ is not computable at level $j+1$.
    have h_ind : ¬ ∃ e, ∀ n, (C.level (j + 1)).φ e n = (C.level k).antidiag n := by
      exact ih k ( j + 1 ) ( by omega ) ( by omega );
    contrapose! h_ind;
    obtain ⟨ e, he ⟩ := h_ind;
    obtain ⟨ e', he' ⟩ := C.extension j |>.extends_base e;
    exact ⟨ e', fun n => by rw [ ← C.coherent j, he', he ] ⟩

/-
**Cumulative Power**: In an oracle chain, any function computable at level k
    is also computable at level k + 1 (but not conversely).
-/
theorem cumulative_power (C : OracleChainData) (k : ℕ)
    (f : ℕ → Bool) (hf : IsComputable (C.level k) f) :
    IsComputable (C.level (k + 1)) f := by
  obtain ⟨ e, he ⟩ := hf;
  -- By (C.extension k).extends_base e, ∃ e', ∀ n, (C.extension k).φ' e' n = (C.level k).φ e n.
  obtain ⟨e', he'⟩ : ∃ e', ∀ n, (C.extension k).φ' e' n = (C.level k).φ e n := by
    exact C.extension k |>.extends_base e;
  exact ⟨ e', fun n => by rw [ C.coherent k ] at he'; aesop ⟩

end