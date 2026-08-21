import Catalog.Geometry.PythagoreanHydra.HydraDepth

/-!
# Calibration of the Pythagorean Hydra: the bound is attained, and descent is necessary

Two complementary results close the analysis of the game.

**Sharpness.**  `exists_maximal_battle` produces, for every hydra `H` of Pythagorean
heads, an actual battle of length exactly `Phi k (H.map bergDepth)`, the upper bound of
`battle_depth_bound`.  Specialised to one head at depth `d` this says the longest battle
has exactly `1 + k + ⋯ + k^d` moves (`single_head_maximal_battle`).  So the length
function of the Pythagorean Hydra is *exactly* the geometric sum — an elementary
function.  There is no room for a Kirby–Paris/Goodstein-style independence phenomenon:
the termination statement comes with a primitive recursive (indeed elementary) witness,
so it is provable by `Σ₁`-induction on the potential.

**Necessity of descent.**  The reason is precisely that inverse Berggren moves go
*down* the tree.  If the regrowth rule is relaxed so that a regrown head may have the
same level (`HydraStepLe`) — let alone a larger one, as happens if the hydra regrows the
Berggren *children* of the chopped head (`BergChopDown`) — then termination fails
outright: `hydraStepLe_has_infinite_play` and `berg_children_infinite_battle` exhibit
explicit infinite plays.  The Pythagorean Hydra therefore sits exactly on the boundary:
strict Berggren descent is both sufficient and necessary for Hercules to win.
-/

namespace PythHydra

/-! ### Sharpness: the maximal battle -/

/-- A head at positive Berggren depth has a Berggren ancestor exactly one level up. -/
theorem exists_parent_ancestor {t : ℤ × ℤ × ℤ} (h : 0 < bergDepth t) :
    ∃ p, IsBergAncestor p t ∧ bergDepth p + 1 = bergDepth t := by
  by_cases hex : ∃ w : List BStep, addr w = t
  · obtain ⟨w, rfl⟩ := hex
    cases w with
    | nil =>
      exfalso
      simp only [bergDepth_addr, List.length_nil] at h
      omega
    | cons s w' =>
      refine ⟨addr w', Relation.TransGen.single ⟨addr_isPPT (s :: w'), addr_hyp_gt_five s w',
        (parent_addr_cons s w').symm⟩, ?_⟩
      rw [bergDepth_addr, bergDepth_addr, List.length_cons]
  · rw [bergDepth, dif_neg hex] at h
    omega

/-- From a non-empty hydra there is a Berggren chop dropping the depth potential by
exactly one. -/
theorem berg_step_depth_pred {k : ℕ} {H : Multiset (ℤ × ℤ × ℤ)} (hH : H ≠ 0) :
    ∃ H', BergChop k H H' ∧ Phi k (H'.map bergDepth) + 1 = Phi k (H.map bergDepth) := by
  obtain ⟨t, hmem⟩ := Multiset.exists_mem_of_ne_zero hH
  obtain ⟨H₀, rfl⟩ := Multiset.exists_cons_of_mem hmem
  rcases Nat.eq_zero_or_pos (bergDepth t) with h0 | hpos
  · refine ⟨H₀, ?_, ?_⟩
    · have h1 : BergChop k (t ::ₘ H₀) (0 + H₀) := BergChop.chop t H₀ 0 (by simp) (by simp)
      simpa using h1
    · simp only [Multiset.map_cons, Phi_cons, h0, phi_zero]
      omega
  · obtain ⟨p, hanc, hdep⟩ := exists_parent_ancestor hpos
    refine ⟨Multiset.replicate k p + H₀, BergChop.chop t H₀ _ ?_ (by simp), ?_⟩
    · intro s hs
      rw [Multiset.eq_of_mem_replicate hs]
      exact hanc
    · rw [Multiset.map_add, Multiset.map_replicate, Multiset.map_cons, Phi_add, Phi_cons,
        Phi_replicate, ← hdep, phi_succ]
      ring

/-- **The upper bound is attained**: every hydra of Pythagorean heads admits a battle of
length exactly `Phi k (H.map bergDepth)` ending with the hydra dead. -/
theorem exists_maximal_battle (k : ℕ) :
    ∀ H : Multiset (ℤ × ℤ × ℤ), Battle k (Phi k (H.map bergDepth)) H 0 := by
  intro H
  generalize hn : Phi k (H.map bergDepth) = n
  induction n using Nat.strong_induction_on generalizing H with
  | _ n ih =>
    rcases eq_or_ne H 0 with rfl | hH
    · simp only [Multiset.map_zero, Phi_zero] at hn
      subst hn
      exact rfl
    · obtain ⟨H', hstep, hPhi⟩ := berg_step_depth_pred (k := k) hH
      obtain ⟨p, rfl⟩ : ∃ p, n = p + 1 := ⟨Phi k (H'.map bergDepth), by omega⟩
      exact ⟨H', hstep, ih p (by omega) H' (by omega)⟩

/-- **The length function of the Pythagorean Hydra.**  Against a single head at Berggren
depth `d = w.length`, with at most `k` heads regrowing per chop, the longest battle has
exactly `phi k d = 1 + k + ⋯ + k^d` moves. -/
theorem single_head_maximal_battle (k : ℕ) (w : List BStep) :
    Battle k (phi k w.length) {addr w} 0 ∧
      ∀ (N : ℕ) (H' : Multiset (ℤ × ℤ × ℤ)), Battle k N {addr w} H' → N ≤ phi k w.length := by
  have hP : Phi k (({addr w} : Multiset (ℤ × ℤ × ℤ)).map bergDepth) = phi k w.length := by
    simp [Phi, bergDepth_addr]
  refine ⟨?_, ?_⟩
  · have := exists_maximal_battle k {addr w}
    rwa [hP] at this
  · intro N H' h
    have := battle_depth_bound h
    omega

/-! ### Necessity: relaxing the descent condition destroys termination -/

/-- The hydra game in which a regrown head may have the *same* level as the chopped one. -/
inductive HydraStepLe : Multiset ℕ → Multiset ℕ → Prop
  | chop (m : ℕ) (H R : Multiset ℕ) (hle : ∀ x ∈ R, x ≤ m) : HydraStepLe (m ::ₘ H) (R + H)

/-- Every genuine (strictly descending) move is a move of the relaxed game. -/
theorem hydraStep_le_of_hydraStep {k : ℕ} {H H' : Multiset ℕ} (h : HydraStep k H H') :
    HydraStepLe H H' := by
  obtain ⟨m, H₀, R, hlt, _⟩ := h
  exact HydraStepLe.chop m H₀ R fun x hx => le_of_lt (hlt x hx)

/-- **Descent is necessary**: with `≤` in place of `<` the game no longer terminates. -/
theorem hydraStepLe_has_infinite_play :
    ∃ f : ℕ → Multiset ℕ, ∀ i, HydraStepLe (f i) (f (i + 1)) := by
  refine ⟨fun _ => {1}, fun _ => ?_⟩
  show HydraStepLe ({1} : Multiset ℕ) {1}
  have h : HydraStepLe ((1 : ℕ) ::ₘ 0) (({1} : Multiset ℕ) + 0) := HydraStepLe.chop 1 0 {1} (by simp)
  simpa using h

/-- The Pythagorean Hydra with the regrowth rule reversed: the regrown heads are the
Berggren *children* of the chopped head (forward Berggren moves, going away from the
root). -/
inductive BergChopDown : Multiset (ℤ × ℤ × ℤ) → Multiset (ℤ × ℤ × ℤ) → Prop
  | chop (t : ℤ × ℤ × ℤ) (H R : Multiset (ℤ × ℤ × ℤ))
      (hR : ∀ s ∈ R, ∃ u : BStep, s = applyStep u t) : BergChopDown (t ::ₘ H) (R + H)

/-- **The Berggren form of the same phenomenon**: if the hydra regrows children instead of
ancestors, Hercules loses — the `B`-spine gives an explicit infinite battle.  This is the
precise sense in which the *descent* structure of the Berggren tree, and nothing else,
is what makes the Pythagorean Hydra terminate. -/
theorem berg_children_infinite_battle :
    ∃ f : ℕ → Multiset (ℤ × ℤ × ℤ), ∀ i, BergChopDown (f i) (f (i + 1)) := by
  refine ⟨fun i => {addr (List.replicate i BStep.B)}, fun i => ?_⟩
  show BergChopDown {addr (List.replicate i BStep.B)} {addr (List.replicate (i + 1) BStep.B)}
  have h1 : ({addr (List.replicate i BStep.B)} : Multiset (ℤ × ℤ × ℤ))
      = addr (List.replicate i BStep.B) ::ₘ 0 := rfl
  have h2 : ({addr (List.replicate (i + 1) BStep.B)} : Multiset (ℤ × ℤ × ℤ))
      = ({addr (List.replicate (i + 1) BStep.B)} : Multiset (ℤ × ℤ × ℤ)) + (0 : Multiset (ℤ × ℤ × ℤ)) := by
    simp
  rw [h1, h2]
  refine BergChopDown.chop _ 0 _ ?_
  intro s hs
  refine ⟨BStep.B, ?_⟩
  rw [Multiset.mem_singleton] at hs
  rw [hs, List.replicate_succ]
  rfl

end PythHydra

/-!
## Lab notes (experimental data, all produced by `#eval` on the definitions above)

Descent of a sample triple under `parent`:
`(117,44,125) → (45,28,53) → (5,12,13) → (3,4,5)`.

Berggren depths of the primitive triples with odd first leg and hypotenuse `≤ 100`:
`(3,4,5) ↦ 0`, `(5,12,13) ↦ 1`, `(15,8,17) ↦ 1`, `(21,20,29) ↦ 1`, `(7,24,25) ↦ 2`,
`(33,56,65) ↦ 2`, `(35,12,37) ↦ 2`, `(39,80,89) ↦ 2`, `(45,28,53) ↦ 2`, `(55,48,73) ↦ 2`,
`(65,72,97) ↦ 2`, `(77,36,85) ↦ 2`, `(9,40,41) ↦ 3`, `(63,16,65) ↦ 3`, `(11,60,61) ↦ 4`,
`(13,84,85) ↦ 5`.

Spines: hypotenuses along `Aⁿ` are `5, 13, 25, 41, 61, 85, 113, 145` (centred squares),
along `Bⁿ` they are `5, 29, 169, 985, 5741, 33461, 195025, 1136689` (Pell/NSW numbers,
`c_{n+2} = 6c_{n+1} − c_n`).  So depth is `Θ(√c)` on one spine and `Θ(log c)` on the other.

Maximal battle lengths `phi k d`:

| d | k=1 | k=2 | k=3 |
|---|-----|-----|-----|
| 0 | 1 | 1 | 1 |
| 1 | 2 | 3 | 4 |
| 2 | 3 | 7 | 13 |
| 3 | 4 | 15 | 40 |
| 4 | 5 | 31 | 121 |
| 5 | 6 | 63 | 364 |
| 6 | 7 | 127 | 1093 |

`phi 3 5 = 364` is the constant appearing in `root_battle_bound`.
-/