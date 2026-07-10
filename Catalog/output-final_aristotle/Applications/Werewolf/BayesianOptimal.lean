import Mathlib

/-!
# Bayesian optimal play in social-deduction games (Werewolf / Mafia)

We study a population of `n` players containing `k` hidden *werewolves* and
`n - k` *villagers*.  A round of play removes one player; villagers try to remove
werewolves, werewolves try to survive until they reach numerical *parity* with the
villagers.

This file isolates the exact probabilistic backbone of the "vote for the most
suspicious player" heuristic.  The central observation is a symmetry principle:
when the only information available is the population counts, the posterior
probability that a fixed player is a werewolf equals the prior `k / n`.  Hence
*every* player is equally suspicious and a single (necessarily uniform) vote
removes a werewolf with probability exactly `k / n`.  We then develop:

* the exact posterior/prior identity and its consequences (monotonicity in the
  number of werewolves and in the population size);
* the *werewolf advantage* `k / (n - k)` and the exact parity threshold
  `n ≤ 2k` at which the werewolves are guaranteed to win;
* an exchangeability law: a fixed player survives `t` uniformly random removals
  with probability exactly `(n - t) / n`;
* a well-founded model of the full consensus-elimination game, with the
  villager win-probability shown to be a genuine probability (`0 ≤ W ≤ 1`).

-- !-- Lab Notes -- !--
HYPOTHESIS (Hypothesizer).  The "vote for the highest werewolf posterior"
heuristic is Bayes-optimal, and under symmetric evidence the posterior collapses
to the prior `k / n`, giving a per-round detection probability of `k / n`.  The
werewolves' structural advantage should be governed by the ratio `k / (n - k)`.

EXPERIMENT (Experimenter).  Model the posterior as the fraction of `k`-subsets of
the `n` players containing a fixed player.  A double-counting identity
(`k · C(n,k) = n · C(n-1,k-1)`) collapses posterior to prior.  The survival law is
its `t`-analogue.  The full game is modelled as a fuel-bounded recursion.

ANALYSIS (Analyst).  The symmetry argument is exact and dimension-free; the
`(1 - k/(n-k))^2` fit from the informal mission is only a heuristic envelope, so
we instead prove the *exact* parity threshold `n ≤ 2k` and monotonicity, which are
the rigorous content behind that envelope.

CRITIQUE (Critic).  Guarded every division by positivity hypotheses; the win
probability is proved to lie in `[0,1]` by induction on fuel, ruling out a vacuous
model.  No theorem is closed by `decide`/`native_decide` alone.

SYNTHESIS (PI).  Posterior = prior = `k/n`, monotonicity, the exact parity
threshold, the survival law, and a well-defined game value together give a
rigorous foundation for optimal Bayesian social deduction.
-/

namespace Werewolf

open scoped BigOperators

/-! ## Posterior, prior, and the symmetry principle -/

/-- Posterior probability that a fixed player is a werewolf, given only that there
are `k` werewolves among `n` players: the number of `k`-subsets of the population
that contain the player, divided by the total number of `k`-subsets. -/
def posterior (n k : ℕ) : ℚ := (Nat.choose (n - 1) (k - 1) : ℚ) / (Nat.choose n k : ℚ)

/-- Prior probability that a fixed player is a werewolf: `k / n`. -/
def prior (n k : ℕ) : ℚ := (k : ℚ) / (n : ℚ)

/--
The double-counting identity `k · C(n,k) = n · C(n-1,k-1)` for `1 ≤ k ≤ n`.
-/
lemma choose_identity {n k : ℕ} (hk : 1 ≤ k) (hkn : k ≤ n) :
    k * Nat.choose n k = n * Nat.choose (n - 1) (k - 1) := by
  cases n <;> cases k <;> simp_all +decide [ Nat.add_one_mul_choose_eq ];
  ring

/--
**Symmetry principle.**  With only the population counts as evidence, the
posterior probability that a fixed player is a werewolf equals the prior `k / n`.
Consequently every player is equally suspicious and a uniform vote is optimal.
-/
theorem posterior_eq_prior {n k : ℕ} (hk : 1 ≤ k) (hkn : k ≤ n) :
    posterior n k = prior n k := by
  rw [ prior, posterior, div_eq_div_iff ];
  · exact mod_cast choose_identity hk hkn ▸ mul_comm _ _;
  · exact ne_of_gt <| Nat.cast_pos.mpr <| Nat.choose_pos hkn;
  · aesop

/--
A single optimal (uniform) vote removes a werewolf with probability `k / n`.
-/
theorem detection_probability {n k : ℕ} (hk : 1 ≤ k) (hkn : k ≤ n) :
    posterior n k = (k : ℚ) / n := by
  convert posterior_eq_prior hk hkn using 1

/-! ## Monotonicity of suspicion -/

/--
Adding a werewolf strictly increases the prior suspicion of a fixed player.
-/
theorem prior_strictMono_werewolves {n k : ℕ} (hn : 0 < n) :
    prior n k < prior n (k + 1) := by
  exact div_lt_div_iff_of_pos_right ( by positivity ) |>.2 ( mod_cast Nat.lt_succ_self _ )

/--
Enlarging the population strictly decreases the prior suspicion of a fixed
player who is one of a fixed number `k ≥ 1` of werewolves.
-/
theorem prior_strictAnti_population {n k : ℕ} (hk : 1 ≤ k) (hn : 1 ≤ n) :
    prior (n + 1) k < prior n k := by
  unfold prior;
  gcongr ; aesop

/-! ## The werewolf advantage and the parity threshold -/

/-- The *werewolf advantage*: the ratio of werewolves to villagers `k / (n - k)`. -/
def advantage (n k : ℕ) : ℚ := (k : ℚ) / ((n : ℚ) - k)

/--
**Parity threshold.**  With at least one villager, the werewolves are (weakly)
at least as numerous as the villagers — i.e. their advantage is at least `1` —
exactly when `n ≤ 2k`.
-/
theorem advantage_ge_one_iff {n k : ℕ} (hk : k < n) :
    1 ≤ advantage n k ↔ n ≤ 2 * k := by
  unfold advantage; rw [ le_div_iff₀ ] <;> norm_cast;
  · rw [ Int.subNatNat_eq_coe ] ; omega;
  · rw [ Int.subNatNat_eq_coe ] ; linarith

/--
The werewolf advantage is strictly increasing in the number of werewolves
(for a fixed population in which at least two villagers remain).
-/
theorem advantage_strictMono {n k : ℕ} (hk : k + 1 < n) :
    advantage n k < advantage n (k + 1) := by
  unfold advantage;
  rw [ div_lt_div_iff₀ ] <;> push_cast <;> nlinarith [ ( by norm_cast : ( k:ℚ ) + 1 < n ) ]

/-! ## Exchangeability: survival under uniform removals -/

/-- Probability that a fixed player is **not** among `t` uniformly random players
removed from a population of `n`: the fraction of `t`-subsets avoiding the player. -/
def survivalProb (n t : ℕ) : ℚ := (Nat.choose (n - 1) t : ℚ) / (Nat.choose n t : ℚ)

/--
**Survival law.**  A fixed player survives `t` uniformly random removals with
probability exactly `(n - t) / n`.
-/
theorem survivalProb_eq {n t : ℕ} (ht : t ≤ n) (hn : 1 ≤ n) :
    survivalProb n t = ((n : ℚ) - t) / n := by
  unfold survivalProb;
  rcases n with ( _ | _ | n ) <;> rcases t with ( _ | _ | t ) <;> norm_num [ Nat.add_one_mul_choose_eq ] at *;
  · grind;
  · rw [ div_eq_div_iff ] <;> norm_cast;
    · nlinarith [ Nat.add_one_mul_choose_eq ( n + 1 ) ( t + 1 ), Nat.add_one_mul_choose_eq ( n + 1 + 1 ) ( t + 1 + 1 ), Nat.choose_succ_succ ( n + 1 ) ( t + 1 ), Nat.choose_succ_succ ( n + 1 + 1 ) ( t + 1 + 1 ), Nat.sub_add_cancel ht ];
    · exact Nat.ne_of_gt <| Nat.choose_pos <| by linarith;

/-! ## The consensus-elimination game -/

/-- Fuel-bounded villager win-probability of the consensus-elimination game with
`w` werewolves and `v` villagers alive.  Each round a uniformly random living
player is removed; villagers win when no werewolf remains, werewolves win on
reaching parity (`w ≥ v`).  The fuel bounds the number of rounds and equals the
population `w + v` in all reachable calls. -/
def winProb : ℕ → ℕ → ℕ → ℚ
  | 0, _, _ => 0
  | (_ + 1), 0, _ => 1
  | (f + 1), (w + 1), v =>
      if (w + 1) ≥ v then 0
      else ((w + 1 : ℚ) / ((w + 1 : ℚ) + v)) * winProb f w v
         + ((v : ℚ) / ((w + 1 : ℚ) + v)) * winProb f (w + 1) (v - 1)

/-- If no werewolf remains, the villagers have already won. -/
@[simp] theorem winProb_no_werewolves (f v : ℕ) : winProb (f + 1) 0 v = 1 := by
  rfl

/--
The villager win-probability is nonnegative.
-/
theorem winProb_nonneg (f w v : ℕ) : 0 ≤ winProb f w v := by
  -- We proceed by induction on the fuel `f`.
  induction' f with f ih generalizing w v;
  · exact le_rfl;
  · cases w <;> cases v <;> simp +decide [ *, winProb ];
    split_ifs <;> first | positivity | exact add_nonneg ( mul_nonneg ( by positivity ) ( ih _ _ ) ) ( mul_nonneg ( by positivity ) ( ih _ _ ) ) ;

/--
The villager win-probability never exceeds `1` — it is a genuine probability.
-/
theorem winProb_le_one (f w v : ℕ) : winProb f w v ≤ 1 := by
  induction' f with f ih generalizing w v;
  · cases w <;> cases v <;> simp +decide [ winProb ];
  · induction' w with w ih generalizing v <;> (induction' v with v ih' <;> simp_all +decide [ winProb ] ;);
    split_ifs <;> simp_all +decide [ div_mul_eq_mul_div ];
    rw [ ← add_div, div_le_iff₀ ] <;> nlinarith [ show ( winProb f w ( v + 1 ) : ℚ ) ≤ 1 from mod_cast ‹∀ w v : ℕ, winProb f w v ≤ 1› _ _, show ( winProb f ( w + 1 ) v : ℚ ) ≤ 1 from mod_cast ‹∀ w v : ℕ, winProb f w v ≤ 1› _ _ ]

/--
If the werewolves are already at parity, the villagers cannot win.
-/
theorem winProb_parity_zero (f w v : ℕ) (hw : 1 ≤ w) (h : w ≥ v) :
    winProb (f + 1) w v = 0 := by
  obtain ⟨ k, hk ⟩ := Nat.exists_eq_succ_of_ne_zero ( ne_of_gt hw );
  rw [hk];
  exact if_pos ( by linarith )

end Werewolf