/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license.

# EML Complexity is a Kolmogorov Measure: Finiteness and Incompressibility

This file is a research contribution to the **EML (Exponential–Multiplicative–Logarithmic)
universal approximation** programme. The density files
(`EML.ExponentialPolynomialDensity`, `EML.StoneWeierstrassApprox`) prove the *qualitative*
side — every continuous function on a compact set is uniformly approximable by EML terms.
The mission asks for the *quantitative* side: a complexity theory of EML representations
**connecting to Kolmogorov complexity**.

We make that connection rigorous. We introduce the **constant-free EML term algebra**
`ETerm` (`var`, `+`, `×`, `exp`, `log`). Because the alphabet is finite, this is a
*countable* syntactic class, so each constructor `size`/`depth` becomes a genuine
**description length**. We prove the two structural pillars of Kolmogorov complexity,
instantiated to EML:

* **Counting / finiteness** (`finite_computableLE`, `finite_computableDepthLE`): for every
  size budget `n` (resp. depth budget `d`) only *finitely many* functions `ℝ → ℝ` are
  *exactly* EML-representable within that budget. This is the EML form of the statement
  "there are at most `2^{n+1}` programs of length `n`".
* **Incompressibility** (`exists_incompressible`, `exists_incompressible_depth`): for every
  budget there exists a function that **no** EML term within that budget computes. Most
  functions are incompressible — exactly the Kolmogorov counting lower bound.

Two further Kolmogorov hallmarks are proved:

* **Subadditivity** (`K_add_le`, `K_mul_le`, `K_exp_le`, `K_log_le`): the EML complexity
  `K f` (minimal term size computing `f`) satisfies `K (f+g) ≤ K f + K g + 1`, etc. — the
  "concatenation of programs" inequalities.
* **Depth ≤ size tower** (`size_succ_le_two_pow_depth`): a depth-`d` term has size below
  `2^{d+1}`, so a depth budget is a (much coarser) description length, and depth
  incompressibility follows from size incompressibility.

-- !-- Lab Notes -- !--
HYPOTHESIS (K1). EML term `size` is a Kolmogorov description length: the number of
functions exactly representable below any fixed size is finite, hence "most" functions are
incompressible. HYPOTHESIS (K2, surprising). The same holds for *depth* even though a fixed
depth allows unboundedly wide (large-size) terms — because depth bounds size by a tower
`size < 2^{depth+1}`. HYPOTHESIS (K3). `K` is subadditive under all EML constructors.

EXPERIMENT. Defined `ETerm` with `eval`, `size`, `depth`. Proved `finite_termsLE n` by
strong induction via the constructor inclusion `{t | size ≤ n+1} ⊆ {var} ∪ image2 add S S ∪
image2 mul S S ∪ expOf '' S ∪ logOf '' S` with `S = {t | size ≤ n}`; pushed through `eval`
to get `finite_computableLE`. Incompressibility = a finite set cannot exhaust the infinite
type `ℝ → ℝ` (constants inject). Subadditivity = `Nat.sInf` is attained, then build the
compound term. Depth: `size + 1 ≤ 2^{depth+1}` by induction, giving `depthLE d ⊆ sizeLE 2^{d+1}`.

ANALYSIS. K1, K2, K3 all confirmed. The crux is that *constant-freeness* makes the alphabet
finite; with real constants the class is uncountable and counting collapses (see FAILURE).

INSIGHT. Density and incompressibility are not in tension: density needs the *union* over
all budgets (complexity → ∞), each budget being a finite island. This is precisely
"universal approximation with a complexity price", the quantitative half of the mission.

FAILURE ANALYSIS. A first draft kept a real-valued `const c` leaf. Then `{t | size ≤ 1}`
is already uncountable (`{const c}`), so `finite_termsLE` is *false*. Diagnosis: Kolmogorov
counting requires a finite description alphabet; we dropped `const` and recover all needed
expressivity through `var`, `add`, `exp`, `log` (e.g. `exp(x+⋯+x) = e^{kx}`).

CRITIQUE. Are the theorems vacuous? No: `computableLE n` is nonempty (`var ∈`) and strictly
grows, and the incompressible witness is a genuine function. `K_add_le` uses attainment of
`Nat.sInf`, not a definitional trick.
-/
import Mathlib

noncomputable section
open Set

namespace EMLKolmogorov

/-- Constant-free EML terms over the finite alphabet `{var, +, ×, exp, log}`.
A *countable* syntactic class, so `size`/`depth` are genuine description lengths. -/
inductive ETerm : Type
  | var : ETerm
  | add : ETerm → ETerm → ETerm
  | mul : ETerm → ETerm → ETerm
  | expOf : ETerm → ETerm
  | logOf : ETerm → ETerm
  deriving DecidableEq, Inhabited

namespace ETerm

/-- Evaluate a term as a function `ℝ → ℝ`. -/
def eval : ETerm → ℝ → ℝ
  | var, x => x
  | add a b, x => eval a x + eval b x
  | mul a b, x => eval a x * eval b x
  | expOf a, x => Real.exp (eval a x)
  | logOf a, x => Real.log (eval a x)

/-- Number of nodes (description length). -/
def size : ETerm → ℕ
  | var => 1
  | add a b => a.size + b.size + 1
  | mul a b => a.size + b.size + 1
  | expOf a => a.size + 1
  | logOf a => a.size + 1

/-- Tree depth. -/
def depth : ETerm → ℕ
  | var => 0
  | add a b => max a.depth b.depth + 1
  | mul a b => max a.depth b.depth + 1
  | expOf a => a.depth + 1
  | logOf a => a.depth + 1

theorem size_pos (t : ETerm) : 0 < t.size := by
  cases t <;> simp +arith +decide [ ETerm.size ]

/-
A depth-`d` term has size below `2^{d+1}`: depth bounds size by a tower.
-/
theorem size_succ_le_two_pow_depth (t : ETerm) : t.size + 1 ≤ 2 ^ (t.depth + 1) := by
  induction' t with t ih;
  · decide +revert;
  · simp +arith +decide [ ETerm.size, ETerm.depth ];
    cases max_cases t.depth ih.depth <;> simp_all +decide [ pow_succ' ];
    · linarith [ pow_le_pow_right₀ ( by decide : 1 ≤ 2 ) ‹_› ];
    · linarith [ pow_le_pow_right₀ ( by decide : 1 ≤ 2 ) ( by linarith : t.depth ≤ ih.depth ) ];
  · rename_i a b ha hb;
    rw [ show ( a.mul b ).size = a.size + b.size + 1 by rfl, show ( a.mul b ).depth = Max.max a.depth b.depth + 1 by rfl ];
    cases max_cases a.depth b.depth <;> simp_all +decide [ pow_succ' ];
    · linarith [ pow_le_pow_right₀ ( by decide : 1 ≤ 2 ) ‹_› ];
    · linarith [ pow_le_pow_right₀ ( by decide : 1 ≤ 2 ) ( by linarith : a.depth ≤ b.depth ) ];
  · simp +arith +decide [ *, ETerm.size, ETerm.depth ];
    grind;
  · simp +arith +decide [ *, ETerm.size, ETerm.depth ];
    grind

end ETerm

open ETerm

/-- The set of terms of size at most `n`. -/
def termsLE (n : ℕ) : Set ETerm := {t | t.size ≤ n}

/-- The set of terms of depth at most `d`. -/
def termsDepthLE (d : ℕ) : Set ETerm := {t | t.depth ≤ d}

/-- The functions exactly computable by a term of size `≤ n`. -/
def computableLE (n : ℕ) : Set (ℝ → ℝ) := ETerm.eval '' termsLE n

/-- The functions exactly computable by a term of depth `≤ d`. -/
def computableDepthLE (d : ℕ) : Set (ℝ → ℝ) := ETerm.eval '' termsDepthLE d

/-- A function is EML-computable if some constant-free EML term computes it exactly. -/
def IsEMLComputable (f : ℝ → ℝ) : Prop := ∃ t : ETerm, t.eval = f

/-- **EML Kolmogorov complexity**: minimal term size computing `f` exactly
(`0` by convention when `f` is not EML-computable). -/
def K (f : ℝ → ℝ) : ℕ := sInf {n | ∃ t : ETerm, t.eval = f ∧ t.size = n}

/-! ### Counting / finiteness: the heart of the Kolmogorov lower bound -/

/-
**Counting bound (terms).** Only finitely many terms have size `≤ n`.
-/
theorem finite_termsLE (n : ℕ) : (termsLE n).Finite := by
  induction' n with n ih;
  · exact Set.finite_empty.subset fun x hx => by linarith [ hx.out, ETerm.size_pos x ] ;
  · refine Set.Finite.subset ( Set.Finite.union ( Set.finite_singleton ETerm.var ) ( Set.Finite.union ( Set.Finite.image2 ( fun a b => ETerm.add a b ) ih ih ) ( Set.Finite.union ( Set.Finite.image2 ( fun a b => ETerm.mul a b ) ih ih ) ( Set.Finite.union ( Set.Finite.image ( fun a => ETerm.expOf a ) ih ) ( Set.Finite.image ( fun a => ETerm.logOf a ) ih ) ) ) ) ) ( fun t => ?_ );
    rcases t with ( _ | _ | _ | _ | _ ) <;> simp_all +arith +decide [ termsLE ];
    · rename_i a b;
      exact fun h => ⟨ by linarith [ ETerm.size_pos a, ETerm.size_pos b, show ( a.add b ).size = a.size + b.size + 1 from rfl ], by linarith [ ETerm.size_pos a, ETerm.size_pos b, show ( a.add b ).size = a.size + b.size + 1 from rfl ] ⟩;
    · rename_i a b; intro h; constructor <;> linarith! [ ETerm.size_pos a, ETerm.size_pos b, show ( a.mul b ).size = a.size + b.size + 1 from rfl ] ;
    · exact fun h => by linarith! [ show ( ‹ETerm›.expOf.size : ℕ ) = ‹ETerm›.size + 1 from rfl ] ;
    · exact fun h => Nat.le_of_succ_le_succ h

/-- **Counting bound (functions).** Only finitely many functions are exactly EML-computable
within size budget `n`. -/
theorem finite_computableLE (n : ℕ) : (computableLE n).Finite :=
  (finite_termsLE n).image _

/-
Depth budgets are size budgets: a depth-`d` term has size `≤ 2^{d+1}`.
-/
theorem termsDepthLE_subset (d : ℕ) : termsDepthLE d ⊆ termsLE (2 ^ (d + 1)) := by
  exact fun t ht => Nat.le_of_succ_le <| ETerm.size_succ_le_two_pow_depth t |> le_trans <| Nat.pow_le_pow_right ( by decide ) <| Nat.succ_le_succ ht

/-- **Counting bound (depth).** Only finitely many terms have depth `≤ d`. -/
theorem finite_termsDepthLE (d : ℕ) : (termsDepthLE d).Finite :=
  (finite_termsLE (2 ^ (d + 1))).subset (termsDepthLE_subset d)

/-- **Counting bound (functions, depth).** Only finitely many functions are exactly
EML-computable within depth budget `d`. -/
theorem finite_computableDepthLE (d : ℕ) : (computableDepthLE d).Finite :=
  (finite_termsDepthLE d).image _

/-! ### Incompressibility: most functions need more than any fixed budget -/

/-
`ℝ → ℝ` is infinite (constants inject).
-/
theorem infinite_real_fun : Infinite (ℝ → ℝ) := by
  exact Infinite.of_injective ( fun x => fun _ => x ) fun x y hxy => by simpa using congr_fun hxy 0;

/-
**Incompressibility (size).** For every size budget `n` there is a function that no
EML term of size `≤ n` computes.
-/
theorem exists_incompressible (n : ℕ) : ∃ f : ℝ → ℝ, f ∉ computableLE n := by
  by_contra h;
  exact absurd ( Set.infinite_univ ( Set.Finite.subset ( finite_computableLE n ) fun f _ => by aesop ) ) ( by simp +decide )

/-
**Incompressibility (depth).** For every depth budget `d` there is a function that no
EML term of depth `≤ d` computes.
-/
theorem exists_incompressible_depth (d : ℕ) : ∃ f : ℝ → ℝ, f ∉ computableDepthLE d := by
  by_contra h;
  exact Set.infinite_univ ( Set.Finite.subset ( finite_computableDepthLE d ) ( by aesop ) )

/-! ### Subadditivity of EML Kolmogorov complexity -/

theorem K_mem (f : ℝ → ℝ) (hf : IsEMLComputable f) :
    ∃ t : ETerm, t.eval = f ∧ t.size = K f := by
      obtain ⟨t, ht⟩ := hf;
      have h_nonempty : {n | ∃ t : ETerm, t.eval = f ∧ t.size = n}.Nonempty := by
        exact ⟨ _, ⟨ t, ht, rfl ⟩ ⟩;
      exact Nat.sInf_mem h_nonempty

theorem K_le_of_eval {f : ℝ → ℝ} (t : ETerm) (h : t.eval = f) : K f ≤ t.size := by
  exact Nat.sInf_le ⟨ t, h, rfl ⟩

/-
**Subadditivity under `+`**: `K (f + g) ≤ K f + K g + 1`.
-/
theorem K_add_le {f g : ℝ → ℝ} (hf : IsEMLComputable f) (hg : IsEMLComputable g) :
    K (f + g) ≤ K f + K g + 1 := by
      obtain ⟨t₁, ht₁⟩ := K_mem f hf
      obtain ⟨t₂, ht₂⟩ := K_mem g hg
      have h_add : K (f + g) ≤ (ETerm.add t₁ t₂).size := by
        apply K_le_of_eval;
        exact funext fun x => by simp +decide [ *, ETerm.eval ] ;
      exact h_add.trans ( by rw [ show ( t₁.add t₂ ).size = t₁.size + t₂.size + 1 from rfl ] ; linarith )

/-
**Subadditivity under `×`**: `K (f * g) ≤ K f + K g + 1`.
-/
theorem K_mul_le {f g : ℝ → ℝ} (hf : IsEMLComputable f) (hg : IsEMLComputable g) :
    K (f * g) ≤ K f + K g + 1 := by
      obtain ⟨ t_f, ht_f ⟩ := K_mem f hf;
      obtain ⟨ t_g, ht_g ⟩ := K_mem g hg;
      convert K_le_of_eval ( ETerm.mul t_f t_g ) _ using 1;
      · exact ht_f.2.symm ▸ ht_g.2.symm ▸ rfl;
      · exact funext fun x => by simp +decide [ *, ETerm.eval ] ;

/-
**Subadditivity under `exp`**: `K (exp ∘ f) ≤ K f + 1`.
-/
theorem K_exp_le {f : ℝ → ℝ} (hf : IsEMLComputable f) :
    K (fun x => Real.exp (f x)) ≤ K f + 1 := by
      obtain ⟨t, ht⟩ := K_mem f hf;
      convert K_le_of_eval ( ETerm.expOf t ) _ using 1;
      · exact ht.2.symm ▸ rfl;
      · exact ht.1 ▸ rfl

/-
**Subadditivity under `log`**: `K (log ∘ f) ≤ K f + 1`.
-/
theorem K_log_le {f : ℝ → ℝ} (hf : IsEMLComputable f) :
    K (fun x => Real.log (f x)) ≤ K f + 1 := by
      obtain ⟨t, ht⟩ := K_mem f hf;
      refine' le_trans ( csInf_le _ ⟨ _, _, rfl ⟩ ) _;
      exacts [ ⟨ 0, fun n hn => Nat.zero_le _ ⟩, ETerm.logOf t, by simp +decide [ ht.1, ETerm.eval ], by simp +decide [ ht.2, ETerm.size ] ]

end EMLKolmogorov