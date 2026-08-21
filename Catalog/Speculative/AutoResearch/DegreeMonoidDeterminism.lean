/-
# Determinism, gaps, and finite-state realisation of degree monoids

Two further layers on top of `Computation.DegreeMonoidRealisation` and
`Computation.DegreeMonoidStructure`.

**Determinism.**  For a *deterministic* transition relation the degree monoid of a state is
closed under subtraction, hence is the full arithmetic progression `dℕ`
(`deterministic_degreeMonoid_dvd`): a deterministic machine has **no gaps**
(`deterministic_no_gaps`).  Consequently the existence of a single gap is a certificate of
nondeterminism (`nondeterministic_of_gap`), and *no* deterministic machine — on any state
space whatsoever — can have the numerical semigroup `⟨2,3⟩` as its degree monoid
(`no_deterministic_realises_two_three`).  The invariant therefore separates deterministic
from nondeterministic computation.

**Finite state spaces.**  Using that every additive submonoid of `ℕ` is finitely generated,
the realisation theorem can be upgraded: every submonoid of `ℕ` is the degree monoid of a
state of a machine with *finitely many* states (`exists_finite_machine`), so finite
nondeterministic machines already realise the whole invariant lattice
(`finite_state_degreeMonoid_range`).

All results are proved with no `sorry`.
-/
import Mathlib
import Computation.DegreeMonoidRealisation
import Computation.DegreeMonoidStructure

namespace Computation
namespace DegreeMonoid

variable {α : Type*}

/-! ## Deterministic systems -/

/-- A transition relation is **deterministic** when each state has at most one successor. -/
def Deterministic (R : α → α → Prop) : Prop := ∀ a b c : α, R a b → R a c → b = c

/-- In a deterministic system a path of given length has a unique endpoint. -/
theorem iterR_unique {R : α → α → Prop} (hdet : Deterministic R) :
    ∀ (n : ℕ) (a b c : α), iterR R n a b → iterR R n a c → b = c := by
  intro n
  induction n with
  | zero => intro a b c hb hc; exact hb ▸ hc
  | succ n ih =>
      rintro a b c ⟨x, hx, hxb⟩ ⟨y, hy, hyc⟩
      have : x = y := hdet a x y hx hy
      subst this
      exact ih x b c hxb hyc

/-- **Subtraction closure.**  The degree monoid of a state of a deterministic system is
closed under (truncated) subtraction. -/
theorem deterministic_sub_mem {R : α → α → Prop} (hdet : Deterministic R) {a : α} {m n : ℕ}
    (hm : m ∈ degreeMonoid R a) (hn : n ∈ degreeMonoid R a) (hmn : m ≤ n) :
    n - m ∈ degreeMonoid R a := by
  have hsplit : n = m + (n - m) := by omega
  rw [hsplit] at hn
  obtain ⟨b, hb1, hb2⟩ := (iterR_add R m (n - m) a a).1 hn
  have : b = a := iterR_unique hdet m a b a hb1 hm
  exact this ▸ hb2

/-- **Determinism forces an arithmetic progression.**  The set of closed-computation lengths
of a state of a deterministic machine is exactly the set of multiples of a single number
(its period). -/
theorem deterministic_degreeMonoid_dvd {R : α → α → Prop} (hdet : Deterministic R) (a : α) :
    ∃ d : ℕ, d ∈ degreeMonoid R a ∧ ∀ n : ℕ, n ∈ degreeMonoid R a ↔ d ∣ n := by
  by_cases hex : ∃ k : ℕ, (k + 1) ∈ degreeMonoid R a
  · classical
    set d := Nat.find hex + 1 with hd
    have hdmem : d ∈ degreeMonoid R a := Nat.find_spec hex
    have hmin : ∀ m ∈ degreeMonoid R a, m ≠ 0 → d ≤ m := by
      intro m hm hm0
      obtain ⟨j, rfl⟩ : ∃ j, m = j + 1 := ⟨m - 1, by omega⟩
      have : Nat.find hex ≤ j := Nat.find_le hm
      omega
    have hmul : ∀ c : ℕ, d * c ∈ degreeMonoid R a := by
      intro c
      induction c with
      | zero => simp
      | succ c ih =>
          have : d * (c + 1) = d * c + d := by ring
          rw [this]
          exact add_mem ih hdmem
    refine ⟨d, hdmem, fun n => ⟨fun hn => ?_, fun ⟨c, hc⟩ => hc ▸ hmul c⟩⟩
    have hdpos : 0 < d := by omega
    have hq : d * (n / d) ∈ degreeMonoid R a := hmul (n / d)
    have hle : d * (n / d) ≤ n := by
      have := Nat.div_add_mod n d
      omega
    have hrem : n - d * (n / d) ∈ degreeMonoid R a := deterministic_sub_mem hdet hq hn hle
    have hmod : n - d * (n / d) = n % d := by
      have := Nat.div_add_mod n d
      omega
    rw [hmod] at hrem
    by_contra hdvd
    have hne : n % d ≠ 0 := fun h => hdvd (Nat.dvd_of_mod_eq_zero h)
    have := hmin _ hrem hne
    have := Nat.mod_lt n hdpos
    omega
  · -- no nonzero closed computation: the degree monoid is `{0}`
    push_neg at hex
    refine ⟨0, zero_mem _, fun n => ⟨fun hn => ?_, fun hn => ?_⟩⟩
    · cases n with
      | zero => exact dvd_rfl
      | succ j => exact absurd hn (hex j)
    · have : n = 0 := Nat.eq_zero_of_zero_dvd hn
      exact this ▸ zero_mem _

/-- For deterministic machines the period generates the whole degree monoid. -/
theorem deterministic_degPeriod_spec {R : α → α → Prop} (hdet : Deterministic R) (a : α) :
    ∀ n : ℕ, n ∈ degreeMonoid R a ↔ degPeriod R a ∣ n := by
  obtain ⟨d, hdmem, hd⟩ := deterministic_degreeMonoid_dvd hdet a
  have h1 : degPeriod R a ∣ d := degPeriod_dvd_mem hdmem
  have h2 : d ∣ degPeriod R a := by
    rw [degPeriod, Nat.dvd_setGcd_iff]
    intro m hm
    exact (hd m).1 (by exact hm)
  have : degPeriod R a = d := Nat.dvd_antisymm h1 h2
  rw [this]
  exact hd

/-- **No gaps.**  A deterministic machine realises *every* multiple of its period as a
closed-computation length. -/
theorem deterministic_no_gaps {R : α → α → Prop} (hdet : Deterministic R) (a : α) :
    {n : ℕ | degPeriod R a ∣ n ∧ n ∉ degreeMonoid R a} = ∅ := by
  ext n
  simp only [Set.mem_setOf_eq, Set.mem_empty_iff_false, iff_false, not_and, not_not]
  intro hdvd
  exact (deterministic_degPeriod_spec hdet a n).2 hdvd

/-- **Gaps certify nondeterminism.**  A single length that is a multiple of the period yet
is not realised proves that the machine is not deterministic. -/
theorem nondeterministic_of_gap {R : α → α → Prop} {a : α} {n : ℕ}
    (hdvd : degPeriod R a ∣ n) (hgap : n ∉ degreeMonoid R a) : ¬ Deterministic R := by
  intro hdet
  have : n ∈ ({n : ℕ | degPeriod R a ∣ n ∧ n ∉ degreeMonoid R a} : Set ℕ) := ⟨hdvd, hgap⟩
  rw [deterministic_no_gaps hdet a] at this
  exact this

/-- **Separation theorem.**  No deterministic machine, on any state space, has the numerical
semigroup `⟨2,3⟩` as the degree monoid of a state: the Frobenius gap `1` is an intrinsic
witness of nondeterminism. -/
theorem no_deterministic_realises_two_three {R : α → α → Prop} (hdet : Deterministic R) (a : α) :
    degreeMonoid R a ≠ AddSubmonoid.closure ({2, 3} : Set ℕ) := by
  intro hEq
  obtain ⟨d, _, hd⟩ := deterministic_degreeMonoid_dvd hdet a
  have h2 : (2 : ℕ) ∈ degreeMonoid R a := by
    rw [hEq]; exact AddSubmonoid.subset_closure (by simp)
  have h3 : (3 : ℕ) ∈ degreeMonoid R a := by
    rw [hEq]; exact AddSubmonoid.subset_closure (by simp)
  have hd2 : d ∣ 2 := (hd 2).1 h2
  have hd3 : d ∣ 3 := (hd 3).1 h3
  have hd1 : d = 1 := Nat.eq_one_of_dvd_coprimes (by decide) hd2 hd3
  have h1 : (1 : ℕ) ∈ degreeMonoid R a := (hd 1).2 (by rw [hd1])
  rw [hEq] at h1
  have : (1 : ℕ) ∈ {k : ℕ | k = 0 ∨ 2 ≤ k} := by
    rw [← closure_two_three]; exact h1
  simp only [Set.mem_setOf_eq] at this
  omega

/-! ## Determinism on a finite state space bounds the period -/

/-- **Period bound for deterministic finite machines.**  On a finite state space a
deterministic machine with a nonempty closed computation has period at most the number of
states: the whole loop through the state consists of pairwise distinct states. -/
theorem deterministic_degPeriod_le_card [Fintype α] {R : α → α → Prop}
    (hdet : Deterministic R) (a : α) (hlive : ∃ n ∈ degreeMonoid R a, n ≠ 0) :
    degPeriod R a ≤ Fintype.card α := by
  classical
  obtain ⟨n0, hn0, hn0'⟩ := hlive
  set d := degPeriod R a with hdd
  have hdpos : 0 < d := degPeriod_pos hn0 hn0'
  have hd : ∀ n : ℕ, n ∈ degreeMonoid R a ↔ d ∣ n := deterministic_degPeriod_spec hdet a
  have hdmem : iterR R d a a := (hd d).2 dvd_rfl
  have hex : ∀ i, i < d → ∃ s, iterR R i a s ∧ iterR R (d - i) s a := by
    intro i hi
    have hsplit : d = i + (d - i) := by omega
    rw [hsplit] at hdmem
    exact (iterR_add R i (d - i) a a).1 hdmem
  have key : ∀ i j : Fin d, i.val < j.val →
      Classical.choose (hex i.1 i.2) ≠ Classical.choose (hex j.1 j.2) := by
    intro i j hij heq
    obtain ⟨hi1, -⟩ := Classical.choose_spec (hex i.1 i.2)
    obtain ⟨-, hj2⟩ := Classical.choose_spec (hex j.1 j.2)
    have hloop : iterR R (i.1 + (d - j.1)) a a :=
      (iterR_add R i.1 (d - j.1) a a).2 ⟨_, hi1, heq ▸ hj2⟩
    have hdvd : d ∣ (i.1 + (d - j.1)) := (hd _).1 hloop
    have h1 : 0 < i.1 + (d - j.1) := by omega
    have h2 : i.1 + (d - j.1) < d := by omega
    have := Nat.le_of_dvd h1 hdvd
    omega
  have hinj : Function.Injective (fun i : Fin d => Classical.choose (hex i.1 i.2)) := by
    intro i j hij
    rcases lt_trichotomy i.val j.val with h | h | h
    · exact absurd hij (key i j h)
    · exact Fin.ext h
    · exact absurd hij.symm (key j i h)
  have := Fintype.card_le_of_injective _ hinj
  simpa using this

/-! ## Finite-state realisation -/

/-- **Finite-state realisation theorem.**  Every additive submonoid of `ℕ` is the degree
monoid of a state of a machine with only finitely many states.  (The state bound comes from
finite generation of submonoids of `ℕ`; nondeterminism is essential by
`no_deterministic_realises_two_three`.) -/
theorem exists_finite_machine (M : AddSubmonoid ℕ) :
    ∃ (B : ℕ) (R : Fin (B + 1) → Fin (B + 1) → Prop) (a : Fin (B + 1)),
      degreeMonoid R a = M := by
  classical
  obtain ⟨t, ht⟩ := Nat.addSubmonoid_fg M
  set B := t.sup id with hB
  have hbound : ∀ s ∈ (t : Set ℕ), s ≤ B := by
    intro s hs
    exact Finset.le_sup (f := id) (by simpa using hs)
  refine ⟨B, fun x y => chainRel (t : Set ℕ) x.val y.val, ⟨0, Nat.succ_pos B⟩, ?_⟩
  have hbisim :
      degreeMonoid (fun x y : Fin (B + 1) => chainRel (t : Set ℕ) x.val y.val)
          ⟨0, Nat.succ_pos B⟩
        = degreeMonoid (chainRel (t : Set ℕ)) 0 := by
    have := degreeMonoid_eq_of_bisim (R := fun x y : Fin (B + 1) => chainRel (t : Set ℕ) x.val y.val)
      (S := chainRel (t : Set ℕ)) (f := Fin.val) Fin.val_injective
      (fun _ _ => Iff.rfl)
      (fun x y hxy => by
        rcases hxy with ⟨_, hmem⟩ | hstep
        · exact ⟨⟨y, by have := hbound (y + 1) hmem; omega⟩, rfl⟩
        · exact ⟨⟨y, by omega⟩, rfl⟩)
      ⟨0, Nat.succ_pos B⟩
    simpa using this
  rw [hbisim, degreeMonoid_chainRel, ht]

/-- Finite nondeterministic machines already realise the entire lattice of degree
monoids. -/
theorem finite_state_degreeMonoid_range :
    {M : AddSubmonoid ℕ |
        ∃ (n : ℕ) (R : Fin n → Fin n → Prop) (a : Fin n), degreeMonoid R a = M} = Set.univ := by
  ext M
  simp only [Set.mem_setOf_eq, Set.mem_univ, iff_true]
  obtain ⟨B, R, a, hR⟩ := exists_finite_machine M
  exact ⟨B + 1, R, a, hR⟩

end DegreeMonoid
end Computation