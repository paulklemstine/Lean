import Mathlib
import Catalog.Logic.ProofComplexity.SimulationPreorder
import Catalog.Logic.ProofComplexity.SimulationDegrees
import Catalog.Logic.ProofComplexity.DegreeLattice
import Catalog.Logic.ProofComplexity.OrderType
import Catalog.Logic.ProofComplexity.NoTopElement

/-! # Embedded suborders of the p-degrees: a chain `ℕ`, and a *bounded* infinite antichain

This file is the **fifth cycle** of the order-theoretic Cook–Reckhow development.  The
earlier files established, for the simulation preorder `Simulates` on abstract proof
systems and the associated poset of p-degrees
`Antisymmetrization (ProofSystem ℕ) (· ≤ ·)`:

* `Simulates` is a `Preorder`, `PEquiv` a `Setoid` (`SimulationPreorder`);
* the master reduction `simulates_sysOfSize_iff` (simulation of size-indexed systems is
  exactly polynomial domination of size functions) and the concrete `linSystem`,
  `fibSystem`, `powSystem k`, `zeroSys`, `spikeSys i` (`SimulationDegrees`, `DegreeLattice`,
  `OrderType`);
* **height** (`powSystem_strictMono`: an infinite strictly increasing chain), **width**
  (`spikeSys_isAntichain`: an infinite antichain), a **bottom** (`zeroSys_isBot`), **no
  top** (`no_top`), binary **meets** (`isGLB_sumSystem`), and local **density**
  (`exists_strictly_between_lin_fib`).

We sharpen the "order type" picture with four results that locate concrete *suborders*
inside the p-degrees:

* **`powSystem_orderEmbedding` — `ℕ` embeds as a chain.**  The growth ladder
  `j ↦ powSystem (j+1)` descends to a genuine *order embedding*
  `ℕ ↪o Antisymmetrization (ProofSystem ℕ) (· ≤ ·)`.  Height is not merely "infinite": the
  p-degrees contain `(ℕ, ≤)` as an ordered subset.

* **`spikeSys_bounded_antichain` — a *bounded* infinite antichain.**  Every spike degree
  lies strictly above the bottom `zeroSys` and below the single degree `powSystem 2`, while
  the spikes remain pairwise incomparable.  Hence even the *finite-height* interval
  `(⊥, powSystem 2]` already has infinite width: width is not pushed off "to infinity" but
  is present arbitrarily low in the order.

* **`powSystem_two_bounds_lin_fib_chain` — height and width share one interval.**  The
  Fibonacci density chain `linSystem < interSys < fibSystem` *also* sits below
  `powSystem 2`.  Combined with the previous result, the bounded interval
  `(⊥, powSystem 2]` simultaneously contains a strict 3-chain and an infinite antichain.

* **`pdegrees_order_type_summary` — capstone.**  A single statement bundling the embedded
  `ℕ`-chain, the (bounded) incomparable pair, the absence of a top, and the existence of a
  bottom: the p-degrees are a bounded-below, top-less, non-linear order of infinite height
  and infinite width.

-- !-- Lab Notebook -- !--
Hypothesis : The qualitative facts proven so far (infinite height, infinite width, bottom,
             no top, density) should sharpen into *embeddings of concrete orders*: an
             order embedding of `(ℕ,≤)`, and an infinite antichain that is *order-bounded*
             (so width occurs inside a finite-height interval, not only "at infinity").
Result     : Confirmed, `sorry = 0`.  `powSystem_orderEmbedding` is a real
             `ℕ ↪o (p-degrees)`; `spikeSys_bounded_antichain` shows the whole spike
             antichain lives in `(⊥, powSystem 2]`; `powSystem_two_bounds_lin_fib_chain`
             puts the density chain in the same interval.
Insight    : The domination characterisation `simulates_sysOfSize_iff` makes "boundedness"
             elementary: `spike n = 2^n` (or 0) and `2^n ≤ 2^(n^2)` because `n ≤ n^2`, so
             the identity blow-up already simulates every spike from `powSystem 2`.  The
             order embedding is just `powSystem_strictMono` transported across
             `toAntisymmetrization_lt_toAntisymmetrization_iff`.  The conceptual payoff:
             the p-degrees are not a "tall thin" or "short fat" order — chains and
             antichains interleave inside one bounded interval.
Failure analysis : A first attempt bounded the spikes by `fibSystem`; this fails because
             `2^n` is *not* polynomially dominated by `Nat.fib n` (`φ < 2`), so spikes are
             not below `fib`.  Moving the ceiling up to the genuinely-exponential
             `powSystem 2` (size `2^(n^2)`) fixes it, since `2^n ≤ 2^(n^2)` pointwise.
-- !-- Lab Notebook -- !--
-/

set_option maxHeartbeats 1000000

namespace ProofComplexity

universe u v

/-! ## `ℕ` embeds as a chain of p-degrees -/

-- !-- comment: `powSystem_strictMono` transported across `toAntisymmetrization` gives a
--             strictly monotone map `ℕ → p-degrees`, hence (ℕ being linearly ordered) an
--             order embedding. -- !--
/-- **`(ℕ, ≤)` embeds into the p-degrees.**  The growth ladder `j ↦ powSystem (j+1)`
descends to an *order embedding* of `ℕ` into the poset of p-degrees: `i ≤ j` iff the degree
of `powSystem (i+1)` is `≤` the degree of `powSystem (j+1)`.  So height is not merely
infinite — the p-degrees contain `(ℕ, ≤)` as an ordered subset. -/
theorem powSystem_orderEmbedding :
    ∃ e : ℕ ↪o Antisymmetrization (ProofSystem.{0, 0} ℕ) (· ≤ ·),
      ∀ j, e j = toAntisymmetrization (· ≤ ·) (powSystem (j + 1)) := by
  refine' ⟨ _, _ ⟩;
  refine' {
      toFun := fun j => toAntisymmetrization ( · ≤ · ) ( powSystem ( j + 1 ) ),
      inj' := _,
      map_rel_iff' := _
    };
  all_goals norm_num [ Function.Injective, toAntisymmetrization_lt_toAntisymmetrization_iff ];
  · convert ProofComplexity.powSystem_pdegrees_injective using 1;
  · intro a b; exact ⟨ fun h => le_of_not_gt fun hab => not_le_of_gt ( powSystem_strictMono hab ) h, fun h => powSystem_strictMono.monotone h ⟩ ;

/-! ## A *bounded* infinite antichain: width arbitrarily low in the order -/

-- !-- comment: `zeroSys` is the bottom and each spike has unbounded size on its support, so
--             `zeroSys < spikeSys i`. -- !--
/-- Each spike degree lies strictly above the bottom: `zeroSys < spikeSys i`. -/
theorem zeroSys_lt_spikeSys (i : ℕ) : zeroSys < spikeSys i := by
  refine' ⟨ _, _ ⟩;
  · exact simulates_zeroSys (spikeSys i);
  · intro h
    obtain ⟨f, hf_mono, hf_bound⟩ := simulates_sysOfSize_iff (fun n => if n.factorization 2 = i then 2 ^ n else 0) (fun _ => 0) |>.1 h;
    -- Choose $n$ such that $n = 2^i * (2k + 1)$ for some $k$ large enough so that $2^n > f(0)$.
    obtain ⟨k, hk⟩ : ∃ k, 2 ^ (2 ^ i * (2 * k + 1)) > f 0 := by
      exact pow_unbounded_of_one_lt _ one_lt_two |> fun ⟨ k, hk ⟩ => ⟨ k, hk.trans_le <| Nat.pow_le_pow_right ( by decide ) <| by nlinarith [ Nat.one_le_pow i 2 zero_lt_two ] ⟩;
    specialize hf_bound ( 2 ^ i * ( 2 * k + 1 ) ) ; simp_all +decide [ Nat.factorization_mul, Nat.factorization_pow ] ;
    split_ifs at hf_bound <;> simp_all +decide [ Nat.factorization_eq_zero_of_not_dvd, Nat.dvd_add_right ];
    linarith

-- !-- comment: `spike n = 2^n` (or 0) and `2^n ≤ 2^(n^2)` since `n ≤ n^2`, so the identity
--             blow-up simulates every spike from `powSystem 2`. -- !--
/-- Every spike degree lies below `powSystem 2`: `powSystem 2` p-simulates `spikeSys i`
(identity blow-up, since `2^n ≤ 2^(n^2)`). -/
theorem spikeSys_le_powSystem_two (i : ℕ) : Simulates (spikeSys i) (powSystem 2) := by
  refine' simulates_sysOfSize_iff _ _ |>.2 _;
  -- Let's choose the identity function as the blow-up function.
  use fun n => n;
  refine' ⟨ polyMono_id, _ ⟩;
  intro n; split_ifs <;> norm_num;
  exact pow_le_pow_right₀ ( by decide ) ( Nat.le_self_pow ( by decide ) _ )

-- !-- comment: Bundling the two bounds with pairwise incomparability: the whole spike
--             antichain lives strictly inside the interval `(⊥, powSystem 2]`. -- !--
/-- **Bounded infinite antichain.**  Every spike degree sits strictly above the bottom
`zeroSys` and below the single degree `powSystem 2`, yet the spikes are pairwise
incomparable.  Thus the bounded interval `(⊥, powSystem 2]` already contains an infinite
antichain: infinite width occurs arbitrarily low in the order, not only "at infinity". -/
theorem spikeSys_bounded_antichain :
    (∀ i, zeroSys < spikeSys i) ∧
    (∀ i, Simulates (spikeSys i) (powSystem 2)) ∧
    (∀ i j, i ≠ j → ¬ Simulates (spikeSys i) (spikeSys j)) :=
  ⟨zeroSys_lt_spikeSys, spikeSys_le_powSystem_two,
    fun _ _ h => spikeSys_incomparable h⟩

/-! ## The density chain shares the same bounded interval -/

-- !-- comment: `fib n ≤ 2^(n^2)` so `fibSystem` (and the whole `lin < inter < fib` chain)
--             is simulated by `powSystem 2`. -- !--
/-- `powSystem 2` p-simulates `fibSystem`: `Nat.fib n ≤ 2^(n^2)`. -/
theorem fibSystem_le_powSystem_two : Simulates fibSystem (powSystem 2) := by
  convert simulates_sysOfSize_iff _ _ |>.2 _;
  use fun n => n;
  refine' ⟨ polyMono_id, fun n => _ ⟩;
  refine' le_trans ( Nat.fib_mono ( show n ≤ n ^ 2 by nlinarith ) ) _;
  exact Nat.recOn ( n ^ 2 ) ( by norm_num ) fun n ihn => by rcases n with ( _ | _ | n ) <;> norm_num [ Nat.pow_succ', Nat.fib_add_two ] at * ; linarith;

-- !-- comment: Height and width inside one finite interval: the density 3-chain and the
--             infinite antichain both live below `powSystem 2`. -- !--
/-- **Height and width in one bounded interval.**  The Fibonacci density chain
`linSystem < interSys < fibSystem` lies below `powSystem 2`, the same ceiling that bounds
the spike antichain.  Hence the bounded interval `(⊥, powSystem 2]` simultaneously contains
a strict 3-chain and an infinite antichain. -/
theorem powSystem_two_bounds_lin_fib_chain :
    linSystem < interSys ∧ interSys < fibSystem ∧
    Simulates fibSystem (powSystem 2) ∧
    (∀ i, Simulates (spikeSys i) (powSystem 2)) :=
  ⟨lin_lt_inter, inter_lt_fib, fibSystem_le_powSystem_two, spikeSys_le_powSystem_two⟩

/-! ## Capstone: the order type at a glance -/

-- !-- comment: One statement: an embedded `ℕ`-chain, an incomparable pair, no top, a
--             bottom — the p-degrees are bounded-below, top-less, non-linear, of infinite
--             height and width. -- !--
/-- **Order-type summary.**  The poset of p-degrees over `ℕ`:
* contains `(ℕ, ≤)` as an ordered subset (an infinite chain), via `powSystem`;
* is *not* linearly ordered — it has an incomparable pair;
* has *no* top element;
* has a bottom element `zeroSys`. -/
theorem pdegrees_order_type_summary :
    (∃ e : ℕ ↪o Antisymmetrization (ProofSystem.{0, 0} ℕ) (· ≤ ·),
        ∀ j, e j = toAntisymmetrization (· ≤ ·) (powSystem (j + 1))) ∧
    (∃ P Q : ProofSystem.{0, 0} ℕ, ¬ Simulates P Q ∧ ¬ Simulates Q P) ∧
    (∀ T : ProofSystem.{0, 0} ℕ, ¬ IsTop T) ∧
    IsBot zeroSys :=
  ⟨powSystem_orderEmbedding, exists_incomparable_pair, no_top, zeroSys_isBot⟩

end ProofComplexity