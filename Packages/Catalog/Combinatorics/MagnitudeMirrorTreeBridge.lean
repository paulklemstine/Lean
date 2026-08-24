/-
# Round-70 #6, cycle 3 — the probe class is closed, the surviving channel is
# strictly outside it, and the square-hit window *is* the Pythagorean tree

Cycles 1–2 (`Combinatorics.MagnitudeMirrorSeal`,
`Combinatorics.MagnitudeMirrorTransfer`) reduced every realized probe of
papers 193/195 to either a structural constant or a deterministic function of
`N`'s magnitude, and characterised the latter exactly.  Cycle 3 answers the two
remaining questions of the round synthesis.

* **Is the seal stable under combining probes?**  Yes, and for a structural
  reason: magnitude mirrors form a *closed class*.  They contain the constants
  (`mirror_const`), are closed under post-processing (`mirror_comp`), under
  pairing (`mirror_pair`), under arbitrary finite tupling (`mirror_tuple`), and
  under refining the magnitude (`mirror_of_refines`).  Hence the whole realized
  battery — bracket sensors, spectral summaries, Gauss magnitudes, any hash of
  them, read *jointly* — is a single mirror, and `round70_joint_seal` closes it
  with exactly zero conditional information against every secret.
* **Is the surviving positional oracle really outside the class?**
  `oracle_informative_within_magnitude_cell` exhibits a magnitude cell on which
  the factor-derived bit `1{d ≤ B}` has strictly positive information: no mirror
  can do this, so the exp551 kill shot provably does not reach it.  The price is
  quantified: `multi_oracle_pigeonhole` shows that reading `L` such bits still
  leaves a class of at least `|Ω| / 2^L` indistinguishable instances, matching
  the stipulated-oracle cost laws of exp547.
* **Where does the geometry live?**  In the Pythagorean tree.  For a *square*
  modulus the Fermat square-hit window is literally the set of Pythagorean
  triples: `pythagorean_of_square_hit` and `square_hit_of_pythagorean` are
  inverse constructions between factorisations `s² = u(u+2k)` and triples
  `(k, s, u+k)`, and `window_offset_of_square` shows the frontier offset from the
  isqrt anchor is `c − s`, obeying the exact identity `(c−s)(c+s) = k²`.
  `square_hit_descends` connects this to the catalog's Berggren machinery: every
  such hit sits above a strictly smaller one in the Barning–Hall descent.  The
  positional oracle reads the leg `k`; every realized probe reads only `|N|`.
-/
import Mathlib
import Combinatorics.MagnitudeMirrorTransfer
import Combinatorics.BerggrenTrees.Parent_hyp_lt
import Shared.CatalogbuildSharedIspythtriple.IsPythTriple

namespace MagnitudeMirror

open Finset Round11

variable {α : Type*} {β γ δ μ : Type*}

/-! ## 1. Magnitude mirrors form a closed probe class -/

/-- A constant sensor — such as the structurally constant bracket sensor of
cycle 1 — is a magnitude mirror. -/
theorem mirror_const {Ω : Finset α} {M : α → μ} (b₀ : β) :
    MirrorsMagnitude Ω (fun _ => b₀) M :=
  ⟨fun _ => b₀, fun _ _ => rfl⟩

/-- Post-processing a mirror gives a mirror. -/
theorem mirror_comp {Ω : Finset α} {Φ : α → β} {M : α → μ} (g : β → δ)
    (h : MirrorsMagnitude Ω Φ M) : MirrorsMagnitude Ω (fun w => g (Φ w)) M := by
  obtain ⟨f, hf⟩ := h
  exact ⟨fun c => g (f c), fun w hw => by dsimp only; rw [hf w hw]⟩

/-- Reading two mirrors jointly gives a mirror. -/
theorem mirror_pair {Ω : Finset α} {Φ₁ : α → β} {Φ₂ : α → δ} {M : α → μ}
    (h₁ : MirrorsMagnitude Ω Φ₁ M) (h₂ : MirrorsMagnitude Ω Φ₂ M) :
    MirrorsMagnitude Ω (fun w => (Φ₁ w, Φ₂ w)) M := by
  obtain ⟨f₁, hf₁⟩ := h₁
  obtain ⟨f₂, hf₂⟩ := h₂
  exact ⟨fun c => (f₁ c, f₂ c), fun w hw => by dsimp only; rw [hf₁ w hw, hf₂ w hw]⟩

/-- Reading an arbitrary finite battery of mirrors jointly gives a mirror. -/
theorem mirror_tuple {Ω : Finset α} {M : α → μ} {n : ℕ} {Φ : Fin n → α → β}
    (h : ∀ i, MirrorsMagnitude Ω (Φ i) M) :
    MirrorsMagnitude Ω (fun w i => Φ i w) M := by
  choose f hf using h
  exact ⟨fun c i => f i c, fun w hw => funext (fun i => hf i w hw)⟩

/-- A mirror of a coarse magnitude is a mirror of any finer magnitude. -/
theorem mirror_of_refines {ν : Type*} {Ω : Finset α} {Φ : α → β} {M : α → μ} {M' : α → ν}
    (hfac : ∃ p : ν → μ, ∀ w ∈ Ω, M w = p (M' w)) (h : MirrorsMagnitude Ω Φ M) :
    MirrorsMagnitude Ω Φ M' := by
  obtain ⟨p, hp⟩ := hfac
  obtain ⟨g, hg⟩ := h
  exact ⟨fun c => g (p c), fun w hw => by rw [hg w hw, hp w hw]⟩

/-- **Joint seal for the realized probe battery.**  Any finite battery of
magnitude mirrors, read jointly and post-processed arbitrarily, still has
*exactly* zero information about every secret inside every magnitude cell — and
any unconditional signal it shows provably comes from stratification of the
secret across magnitude cells, not from transfer. -/
theorem round70_joint_seal [DecidableEq γ] [DecidableEq δ] [DecidableEq μ]
    {Ω : Finset α} {M : α → μ} {S : α → γ} {n : ℕ} {Φ : Fin n → α → β}
    (g : (Fin n → β) → δ) (h : ∀ i, MirrorsMagnitude Ω (Φ i) M) :
    (∀ c : μ, ZeroInfo (Ω.filter fun w => M w = c) (fun w => g (fun i => Φ i w)) S) ∧
      (¬ ZeroInfo Ω (fun w => g fun i => Φ i w) S →
        ∃ c ∈ Ω.image M, ∃ s : γ,
          #((Ω.filter fun w => M w = c).filter fun w => S w = s) * #Ω
            ≠ #(Ω.filter fun w => M w = c) * #(Ω.filter fun w => S w = s)) := by
  have hmir : MirrorsMagnitude Ω (fun w => g fun i => Φ i w) M :=
    mirror_comp g (mirror_tuple h)
  exact ⟨fun c => mirror_conditional_zeroInfo S hmir c,
    fun hsig => mirror_signal_forces_stratification hmir hsig⟩

/-! ## 2. The positional oracle is strictly outside the class -/

/-- **Sharp boundary.**  Inside a single magnitude cell — here the two instances
`14 = 2·7` and `15 = 3·5`, which share the coarse magnitude bucket `⌊N/8⌋ = 1` —
the factor-derived bit `1{d ≤ 2}` still has strictly positive information about a
secret.  By `mirror_conditional_zeroInfo` no magnitude mirror can do this, so the
exp551 collapse argument cannot be applied to the positional oracle. -/
theorem oracle_informative_within_magnitude_cell :
    ¬ ZeroInfo ((({(2, 7), (3, 5)} : Finset (ℕ × ℕ)).filter fun p => (p.1 * p.2) / 8 = 1))
        (fun p : ℕ × ℕ => if p.1 ≤ 2 then 1 else 0) (fun p : ℕ × ℕ => p.2 % 4) := by
  have h : (({(2, 7), (3, 5)} : Finset (ℕ × ℕ)).filter fun p => (p.1 * p.2) / 8 = 1)
      = {(2, 7), (3, 5)} := by decide
  rw [h]
  exact positional_oracle_informative

/-- **No amplification from the surviving channel.**  Reading `L` Boolean
oracle bits at once still leaves a class of at least `|Ω| / 2^L` mutually
indistinguishable instances: the positional channel is real but its yield is
capped at one bit per read. -/
theorem multi_oracle_pigeonhole (Ω : Finset α) (L : ℕ) (T : Fin L → α → Bool) :
    ∃ c : Fin L → Bool, #Ω ≤ 2 ^ L * #(Ω.filter fun w => (fun i => T i w) = c) := by
  classical
  set R : α → (Fin L → Bool) := fun w i => T i w with hR
  have hsum : ∑ c : Fin L → Bool, #(Ω.filter fun w => R w = c) = #Ω :=
    (Finset.card_eq_sum_card_fiberwise (f := R) (t := Finset.univ)
      (fun w _ => Finset.mem_univ _)).symm
  obtain ⟨c, -, hc⟩ := Finset.exists_max_image (Finset.univ : Finset (Fin L → Bool))
    (fun c => #(Ω.filter fun w => R w = c)) ⟨default, Finset.mem_univ _⟩
  refine ⟨c, ?_⟩
  calc #Ω = ∑ c' : Fin L → Bool, #(Ω.filter fun w => R w = c') := hsum.symm
  _ ≤ ∑ _c' : Fin L → Bool, #(Ω.filter fun w => R w = c) :=
      Finset.sum_le_sum (fun c' hc' => hc c' hc')
  _ = 2 ^ L * #(Ω.filter fun w => R w = c) := by
      rw [Finset.sum_const, smul_eq_mul, Finset.card_univ]
      simp

/-! ## 3. The square-hit window is the Pythagorean tree -/

/-- **From a square-hit to a triple.**  A factorisation `s² = u(u+2k)` of a
perfect square is exactly a Pythagorean triple `(k, s, u+k)`: the Fermat window
over square moduli enumerates the Pythagorean tree. -/
theorem pythagorean_of_square_hit {u k s : ℕ} (h : u * (u + 2 * k) = s ^ 2) :
    IsPythTriple (k : ℤ) (s : ℤ) ((u : ℤ) + k) := by
  have hZ : (u : ℤ) * ((u : ℤ) + 2 * k) = (s : ℤ) ^ 2 := by exact_mod_cast h
  unfold IsPythTriple
  nlinarith [hZ]

/-- **From a triple to a square-hit.**  Conversely every Pythagorean triple
`(k, s, c)` with `k ≤ c` gives a factorisation of the square `s²` of the Fermat
shape, with `u = c − k`. -/
theorem square_hit_of_pythagorean {k s c : ℕ} (hk : k ≤ c)
    (h : IsPythTriple (k : ℤ) (s : ℤ) (c : ℤ)) :
    (c - k) * ((c - k) + 2 * k) = s ^ 2 := by
  obtain ⟨u, hu⟩ : ∃ u, c = u + k := ⟨c - k, by omega⟩
  have hZ : (k : ℤ) ^ 2 + (s : ℤ) ^ 2 = (c : ℤ) ^ 2 := h
  have hcu : (c : ℤ) = (u : ℤ) + k := by exact_mod_cast hu
  have hgoal : ((u : ℤ)) * ((u : ℤ) + 2 * k) = (s : ℤ) ^ 2 := by
    rw [hcu] at hZ; nlinarith [hZ]
  have hsub : c - k = u := by omega
  rw [hsub]
  exact_mod_cast hgoal

/-- **The frontier identity over square moduli.**  For `N = s²` the isqrt anchor
is `s` itself, the Fermat centre is the hypotenuse `c = u + k`, and the frontier
offset `c − s` satisfies the exact identity `(c − s)(c + s) = k²`: the ascent
distance is the square of the Pythagorean leg divided by `c + s`. -/
theorem window_offset_of_square {u k s : ℕ} (h : u * (u + 2 * k) = s ^ 2) :
    Nat.sqrt (u * (u + 2 * k)) = s ∧ ((u + k) - s) * ((u + k) + s) = k ^ 2 := by
  have hsq : Nat.sqrt (u * (u + 2 * k)) = s := by
    rw [h, pow_two, Nat.sqrt_eq]
  refine ⟨hsq, ?_⟩
  have hle : s ≤ u + k := by
    have := anchor_le_center u k
    rwa [hsq] at this
  obtain ⟨j, hj⟩ : ∃ j, u + k = s + j := ⟨(u + k) - s, by omega⟩
  have hjeq : (u + k) - s = j := by omega
  rw [hjeq]
  have hZ : (u : ℤ) * ((u : ℤ) + 2 * k) = (s : ℤ) ^ 2 := by exact_mod_cast h
  have hcZ : ((u : ℤ) + k) = (s : ℤ) + j := by exact_mod_cast hj
  have : (j : ℤ) * ((s : ℤ) + j + s) = (k : ℤ) ^ 2 := by nlinarith [hZ, hcZ]
  have hfin : (j : ℤ) * (((s : ℤ) + j) + s) = (k : ℤ) ^ 2 := this
  rw [← hcZ] at hfin
  exact_mod_cast hfin

/-- **Berggren descent of square-hits.**  Every square-hit with positive leg and
positive root yields a Pythagorean triple whose Barning–Hall parent hypotenuse is
strictly smaller: the hits over square moduli are the nodes of the catalog's
Pythagorean tree, and the frontier ascent is a walk in that tree.  (Uses the
catalog's `parent_hyp_lt`.) -/
theorem square_hit_descends {u k s : ℕ} (hk : 0 < k) (hs : 0 < s)
    (h : u * (u + 2 * k) = s ^ 2) :
    -2 * (k : ℤ) - 2 * (s : ℤ) + 3 * ((u : ℤ) + k) < (u : ℤ) + k := by
  refine parent_hyp_lt (k : ℤ) (s : ℤ) ((u : ℤ) + k) (by exact_mod_cast hk)
    (by exact_mod_cast hs) ?_
  have := pythagorean_of_square_hit h
  unfold IsPythTriple at this
  unfold IsPT
  exact this

/-- Non-vacuity of the bridge: `12² = 144 = 8·18` is the square-hit presentation
of the triple `(5, 12, 13)`, with frontier offset `13 − 12 = 1` and identity
`1 · 25 = 5²`. -/
theorem pythagorean_bridge_example :
    8 * (8 + 2 * 5) = 12 ^ 2 ∧ IsPythTriple (5 : ℤ) (12 : ℤ) (13 : ℤ) ∧
      ((8 + 5) - 12) * ((8 + 5) + 12) = 5 ^ 2 := by
  refine ⟨by norm_num, ?_, by norm_num⟩
  have := pythagorean_of_square_hit (u := 8) (k := 5) (s := 12) (by norm_num)
  norm_num at this ⊢
  exact this

end MagnitudeMirror