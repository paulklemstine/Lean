import Mathlib
import Catalog.Logic.ProofComplexity.SimulationPreorder
import Catalog.Logic.ProofComplexity.SimulationDegrees

/-! # Lattice shape and parametric separation of the poset of p-degrees

This file extends the order-theoretic core of the Cook–Reckhow program developed in
`Catalog.Logic.ProofComplexity.SimulationPreorder` (the simulation preorder `Simulates`,
its `Preorder` instance `simulationPreorder`, `PolyBounded`/`PolyMono`, the Fibonacci
super-polynomiality `not_polyBounded_fib`) and
`Catalog.Logic.ProofComplexity.SimulationDegrees` (the generic separation template
`no_simulation_of_hard`, and the concrete `linSystem` / `fibSystem`).

We answer two structural questions about the **poset of p-degrees**
(`Antisymmetrization (ProofSystem Thm) (· ≤ ·)`):

* **Lattice shape.**  Binary *meets* always exist: the direct-sum proof system
  `sumSystem P Q` (proofs are `P.Proof ⊕ Q.Proof`) is the greatest lower bound of
  `{P, Q}` in the simulation preorder (`isGLB_sumSystem`).  Hence the simulation preorder
  is down-directed (`simulation_directed`) and the p-degrees form a meet-semilattice.

* **Parametric separation / infinite height.**  Beyond the single Fibonacci separation
  `lin_lt_fib`, the size functions `n ↦ 2 ^ (n ^ k)` give an **infinite strictly increasing
  chain** of p-degrees (`powSystem_strictMono`): each polynomial step in the exponent is a
  super-polynomial jump in size, so the poset of p-degrees has infinite height.

-- !-- Lab Notebook -- !--
Hypothesis : (1) The simulation preorder should have binary meets, realised concretely by
             a "run both systems" direct sum.  (2) Beyond one Fibonacci separation the
             degree poset should have infinite height, witnessed by a growth ladder whose
             consecutive rungs are separated by a super-polynomial gap.
Result     : Both confirmed, `sorry = 0`.  `isGLB_sumSystem` exhibits the meet; the
             characterisation `simulates_sysOfSize_iff` reduces simulation between
             `ℕ`-indexed size systems to pointwise polynomial domination, turning the
             chain into the elementary growth fact `pow_pow_succ_gap`.
Insight    : The right invariant is *polynomial domination of size functions*: `sys a`
             p-simulates `sys b` iff `a ≤ poly ∘ b`.  Lattice meets correspond to the
             pointwise `min`-in-strength (= `max` of blow-ups), and height corresponds to
             chains of growth rates that are not polynomially comparable.  The ladder
             `2 ^ (n ^ k)` works precisely because `n ^ (k+1) = n · n ^ k` outruns
             `c · n ^ k + c` for `n > c`, whereas a plain exponential `2 ^ (k·n)` would
             collapse (all such rungs are polynomially comparable).
Failure analysis : A first ladder attempt used `2 ^ (k * n)`; it collapses because
             `2 ^ ((k+1) n) ≤ (2 ^ (k n)) ^ 2`, i.e. consecutive rungs are p-equivalent.
             Moving the parameter into the *exponent of the exponent* (`n ^ k`) creates a
             genuinely non-polynomial gap.  The `k = 0` rung (constant size) needs a
             separate argument, so the published chain starts at `k = 1`.
-- !-- Lab Notebook -- !--
-/

set_option maxHeartbeats 1000000

namespace ProofComplexity

universe u v

variable {Thm : Type u}

/-! ## The direct-sum proof system and binary meets -/

-- !-- comment: `sumSystem P Q` runs whichever of `P`, `Q` you like: proofs are the disjoint
--             union, and `proves`/`size` are read off componentwise. -- !--
/-- The **direct sum** of two proof systems for the same theorem type: a proof is either a
`P`-proof or a `Q`-proof, certifying the same theorem with the same size. -/
def sumSystem (P Q : ProofSystem.{u, v} Thm) : ProofSystem.{u, v} Thm where
  Proof := P.Proof ⊕ Q.Proof
  proves := Sum.elim P.proves Q.proves
  size := Sum.elim P.size Q.size
  complete := by
    intro t
    obtain ⟨p, hp⟩ := P.complete t
    exact ⟨Sum.inl p, hp⟩

-- !-- comment: `max` of two blow-ups is again a monotone polynomial blow-up — the
--             algebra behind closing the meet under the universal property. -- !--
/-- The pointwise maximum of two monotone polynomially-bounded blow-ups is again one. -/
lemma polyMono_max {f g : ℕ → ℕ} (hf : PolyMono f) (hg : PolyMono g) :
    PolyMono (fun n => max (f n) (g n)) := by
      refine' ⟨ fun n m hnm => _, _ ⟩;
      · exact max_le_max ( hf.1 hnm ) ( hg.1 hnm );
      · obtain ⟨ k₁, hk₁ ⟩ := hf.2
        obtain ⟨ k₂, hk₂ ⟩ := hg.2
        use k₁ + k₂ + 1
        intro n
        have h1 : f n + 1 ≤ (n + 2) ^ k₁ := hk₁ n
        have h2 : g n + 1 ≤ (n + 2) ^ k₂ := hk₂ n
        have h3 : (n + 2) ^ k₁ ≤ (n + 2) ^ (k₁ + k₂ + 1) := by
          exact pow_le_pow_right₀ ( by linarith ) ( by linarith )
        have h4 : (n + 2) ^ k₂ ≤ (n + 2) ^ (k₁ + k₂ + 1) := by
          exact pow_le_pow_right₀ ( by linarith ) ( by linarith )
        have h5 : max (f n) (g n) + 1 ≤ (n + 2) ^ (k₁ + k₂ + 1) := by
          grind
        exact h5

/-- The direct sum p-simulates its left summand (identity blow-up via `Sum.inl`). -/
lemma simulates_sumSystem_left (P Q : ProofSystem.{u, v} Thm) :
    Simulates (sumSystem P Q) P := by
      refine' ⟨ fun n => n, polyMono_id, fun q => ⟨ Sum.inl q, rfl, _ ⟩ ⟩;
      rfl

/-- The direct sum p-simulates its right summand (identity blow-up via `Sum.inr`). -/
lemma simulates_sumSystem_right (P Q : ProofSystem.{u, v} Thm) :
    Simulates (sumSystem P Q) Q := by
      refine' ⟨ fun n => n, polyMono_id, fun q => ⟨ Sum.inr q, rfl, _ ⟩ ⟩;
      rfl

/-- Universal property of the meet: any `R` that simulates both `P` and `Q` simulates the
direct sum (using the `max` of the two blow-ups). -/
lemma simulates_sumSystem_of_simulates_both {R P Q : ProofSystem.{u, v} Thm}
    (hP : Simulates R P) (hQ : Simulates R Q) : Simulates R (sumSystem P Q) := by
      obtain ⟨ f₁, hf₁, hf₁' ⟩ := hP
      obtain ⟨ f₂, hf₂, hf₂' ⟩ := hQ;
      refine' ⟨ fun n => Max.max ( f₁ n ) ( f₂ n ), _, _ ⟩;
      · exact polyMono_max hf₁ hf₂;
      · rintro ( q | q ) <;> [ exact hf₁' q |> fun ⟨ p, hp₁, hp₂ ⟩ => ⟨ p, hp₁, le_max_of_le_left hp₂ ⟩ ; exact hf₂' q |> fun ⟨ p, hp₁, hp₂ ⟩ => ⟨ p, hp₁, le_max_of_le_right hp₂ ⟩ ]

-- !-- comment: Packaging the three facts: `sumSystem P Q` is the GLB of `{P,Q}` in the
--             simulation preorder, so binary meets exist. -- !--
/-- **Lattice shape (meets exist).**  In the simulation preorder, `sumSystem P Q` is the
greatest lower bound of `{P, Q}`.  Equivalently, the poset of p-degrees has binary meets. -/
theorem isGLB_sumSystem (P Q : ProofSystem.{u, v} Thm) :
    IsGLB ({P, Q} : Set (ProofSystem.{u, v} Thm)) (sumSystem P Q) := by
      refine' ⟨ _, fun R hR => _ ⟩;
      · rintro R ( rfl | rfl ) <;> [ exact simulates_sumSystem_left P Q; exact simulates_sumSystem_right P Q ];
        · exact simulates_sumSystem_left R Q;
        · exact simulates_sumSystem_right P R;
      · exact simulates_sumSystem_of_simulates_both ( hR ( Set.mem_insert _ _ ) ) ( hR ( Set.mem_insert_of_mem _ ( Set.mem_singleton _ ) ) )

/-- **The simulation preorder is down-directed.**  Any two proof systems have a common
lower bound, namely their direct sum. -/
theorem simulation_directed (P Q : ProofSystem.{u, v} Thm) :
    ∃ R, Simulates R P ∧ Simulates R Q :=
  ⟨sumSystem P Q, simulates_sumSystem_left P Q, simulates_sumSystem_right P Q⟩

/-! ## Size-indexed systems over `ℕ` and the domination characterisation -/

-- !-- comment: A proof system over `ℕ` whose proof of `n` is `n` itself, with prescribed
--             size `a n`; `linSystem`/`fibSystem` are the cases `a = id`, `a = fib`. -- !--
/-- The proof system over `ℕ` with `proves = id` and prescribed size function `a`. -/
def sysOfSize (a : ℕ → ℕ) : ProofSystem.{0, 0} ℕ where
  Proof := ℕ
  proves := id
  size := a
  complete := Function.surjective_id

-- !-- comment: For size-indexed systems, simulation is *exactly* polynomial domination of
--             size functions — the master reduction making every separation arithmetic. -- !--
/-- **Domination characterisation.**  `sysOfSize a` p-simulates `sysOfSize b` iff `a` is
pointwise dominated by a monotone polynomial blow-up of `b`. -/
theorem simulates_sysOfSize_iff (a b : ℕ → ℕ) :
    Simulates (sysOfSize a) (sysOfSize b) ↔ ∃ f, PolyMono f ∧ ∀ n, a n ≤ f (b n) := by
      constructor;
      · rintro ⟨ f, hf, h ⟩;
        exact ⟨ f, hf, fun n => by obtain ⟨ p, hp₁, hp₂ ⟩ := h n; exact hp₂ |> le_trans ( by aesop ) ⟩;
      · rintro ⟨ f, hf, h ⟩;
        exact ⟨ f, hf, fun q => ⟨ q, rfl, h q ⟩ ⟩

/-! ## The Fibonacci separation as a strict 2-chain -/

-- !-- comment: `lin` simulates `fib` (small proofs are cheap) but not conversely, so
--             `linSystem < fibSystem` strictly in the preorder. -- !--
/-- `linSystem` p-simulates `fibSystem`: `n ≤ F n + 4`, a polynomial (indeed linear) bound. -/
lemma simulates_lin_fib : Simulates linSystem fibSystem := by
  refine' ⟨ fun n => n + 4, _, _ ⟩;
  · constructor;
    · exact fun m n h => Nat.add_le_add_right h 4;
    · exact ⟨ 3, fun n => by nlinarith [ sq n ] ⟩;
  · intro q;
    rcases q with ( _ | _ | _ | _ | _ | q ) <;> simp +arith +decide [ linSystem, fibSystem ];
    linarith [ Nat.le_fib_add_one ( q + 5 ) ]

/-- `fibSystem` does **not** p-simulate `linSystem` (the catalog's Fibonacci separation). -/
lemma not_simulates_fib_lin : ¬ Simulates fibSystem linSystem := by
  intro h;
  obtain ⟨ f, hf, hf' ⟩ := h;
  -- Since `fibSystem` is defined as the system with size function `Nat.fib`, we have `fibSystem.size p = Nat.fib p`.
  simp [linSystem, fibSystem] at hf';
  exact no_poly_bound_dominates_fib hf' hf.2

/-- **Strict 2-chain.**  `linSystem < fibSystem` in the simulation preorder: the poset of
p-degrees has at least two strictly comparable points (height `≥ 2`). -/
theorem lin_lt_fib : linSystem < fibSystem :=
  lt_of_le_not_ge simulates_lin_fib not_simulates_fib_lin

/-! ## An infinite strictly increasing chain: infinite height -/

-- !-- comment: The growth ladder `2 ^ (n ^ k)`; bumping `k` is a super-polynomial jump. -- !--
/-- The proof system over `ℕ` whose proof of `n` has size `2 ^ (n ^ k)`. -/
def powSystem (k : ℕ) : ProofSystem.{0, 0} ℕ := sysOfSize (fun n => 2 ^ (n ^ k))

-- !-- comment: The arithmetic heart: `2 ^ (n^(k+1))` is not bounded by any polynomial in
--             `2 ^ (n^k)`, because `n^(k+1) = n·n^k` beats `c·n^k + c` once `n > c`. -- !--
/-- For `k ≥ 1` and every exponent `c`, there is an `n` with
`(2 ^ (n ^ k) + 2) ^ c < 2 ^ (n ^ (k + 1))`: the consecutive rungs of the ladder are
*not* polynomially comparable. -/
lemma pow_pow_succ_gap (k : ℕ) (hk : 1 ≤ k) (c : ℕ) :
    ∃ n, (2 ^ (n ^ k) + 2) ^ c < 2 ^ (n ^ (k + 1)) := by
      by_cases hc : c = 0;
      · exact ⟨ 1, by norm_num [ hc ] ⟩;
      · use c + 2;
        refine' lt_of_le_of_lt ( Nat.pow_le_pow_left ( show 2 ^ ( c + 2 ) ^ k + 2 ≤ 2 ^ ( ( c + 2 ) ^ k + 1 ) from _ ) _ ) _;
        · rw [ pow_succ' ] ; linarith [ Nat.pow_le_pow_right ( by decide : 1 ≤ 2 ) ( show ( c + 2 ) ^ k ≥ 1 by exact Nat.one_le_pow _ _ ( by linarith ) ) ];
        · rw [ ← pow_mul ] ; gcongr;
          · norm_num;
          · rw [ pow_succ' ] ; nlinarith [ Nat.pos_of_ne_zero hc, Nat.pow_le_pow_right ( by linarith : 1 ≤ c + 2 ) hk ]

/-- Lower rung simulates the upper one: `2 ^ (n^k) ≤ 2 ^ (n^(k+1)) + 2`. -/
lemma simulates_powSystem_succ (k : ℕ) :
    Simulates (powSystem k) (powSystem (k + 1)) := by
      convert simulates_sysOfSize_iff _ _ |>.2 _;
      refine' ⟨ _, _, _ ⟩;
      exact fun n => n + 2;
      · constructor;
        · exact monotone_id.add_const 2;
        · exact ⟨ 2, fun n => by nlinarith [ sq n ] ⟩;
      · intro n; cases n <;> simp +arith +decide [ Nat.pow_succ' ] ;
        · cases k <;> norm_num;
        · exact le_add_of_le_of_nonneg ( pow_le_pow_right₀ ( by decide ) ( Nat.le_mul_of_pos_left _ ( Nat.succ_pos _ ) ) ) ( by decide )

/-- Upper rung does **not** simulate the lower one (super-polynomial gap), for `k ≥ 1`. -/
lemma not_simulates_powSystem_succ (k : ℕ) (hk : 1 ≤ k) :
    ¬ Simulates (powSystem (k + 1)) (powSystem k) := by
      intro h
      obtain ⟨f, hf_mono, hf_bound⟩ := simulates_sysOfSize_iff (fun n => 2 ^ (n ^ (k + 1))) (fun n => 2 ^ (n ^ k)) |>.1 h;
      obtain ⟨ c, hc ⟩ := hf_mono.2;
      obtain ⟨ n, hn ⟩ := pow_pow_succ_gap k hk c;
      grind

/-- Each step of the ladder (from `k ≥ 1`) is a strict increase in the preorder. -/
theorem powSystem_lt_succ (k : ℕ) (hk : 1 ≤ k) :
    powSystem k < powSystem (k + 1) :=
  lt_of_le_not_ge (simulates_powSystem_succ k) (not_simulates_powSystem_succ k hk)

-- !-- comment: Strict monotonicity of `j ↦ powSystem (j+1)` packages an infinite strictly
--             increasing chain of p-degrees: the poset has infinite height. -- !--
/-- **Infinite height.**  `j ↦ powSystem (j + 1)` is a strictly increasing chain in the
simulation preorder, so the poset of p-degrees contains an infinite strictly increasing
chain. -/
theorem powSystem_strictMono : StrictMono (fun j => powSystem (j + 1)) :=
  strictMono_nat_of_lt_succ fun j => powSystem_lt_succ (j + 1) (Nat.le_add_left 1 j)

/-- The infinite chain descends to genuinely distinct p-degrees: `j ↦ [powSystem (j+1)]`
is injective into the poset `Antisymmetrization (ProofSystem ℕ) (· ≤ ·)`. -/
theorem powSystem_pdegrees_injective :
    Function.Injective
      (fun j => (toAntisymmetrization (· ≤ ·) (powSystem (j + 1)))) := by
        intro i j hij;
        simp_all +decide [ toAntisymmetrization ];
        rw [ Quotient.eq ] at hij;
        cases lt_trichotomy i j <;> simp_all +decide [ AntisymmRel.setoid ];
        · have := powSystem_strictMono ‹_›;
          exact absurd hij.2 ( not_le_of_gt this );
        · cases ‹_› <;> simp_all +decide [ AntisymmRel ];
          exact absurd hij.1 ( not_le_of_gt ( powSystem_strictMono ( by linarith ) ) )

end ProofComplexity