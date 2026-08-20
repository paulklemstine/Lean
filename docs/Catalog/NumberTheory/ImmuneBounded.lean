import Catalog.Shared.ImmuneEnsemble

/-!
# Algorithmic Immune System, Part VIII: bounded universes — perfect immunity and its price

Parts III, V and VII are impossibility results; Part IV gives containment at the
price of rigidity.  This part identifies the regime in which the algorithmic
immune system is *provably perfect*, and computes the price exactly.

Fix a size bound `N` and a literal bound `L`.  The programs of size `≤ N` whose
literals are `< L` form a finite universe (`mem_astUniverse`), so the monitor can
whitelist **all** benign programs of that universe:

* `bounded_perfect_immunity` — there is a whitelist `S` with
  * containment: every sanctioned program is harmless, hence by Part IV no
    adversary ever triggers the forbidden action, and
  * *zero false positives inside the universe*: every harmless program of the
    universe is accepted.
* `bounded_immunity_memory_lower_bound` — but any such whitelist has at least
  `2 ^ n` entries whenever `3n + 1 ≤ N` and `2 ≤ L`; i.e. its memory is
  exponential in the size bound, `2 ^ ((N-1)/3)`.

So perfect algorithmic immunity is attainable exactly on bounded code universes,
and the attestation database must then be exponentially large: the impossibility
results of Parts III/V/VII are the `N → ∞` limit of this trade-off.
-/

namespace ImmuneSystem
namespace PAst

open Finset

/-- All literals occurring in the program are `< L`. -/
def litsBelow (L : ℕ) : PAst → Bool
  | inp => true
  | attack => true
  | lit n => decide (n < L)
  | ite c a b => litsBelow L c && litsBelow L a && litsBelow L b
  | call f a => litsBelow L f && litsBelow L a

@[simp] theorem litsBelow_inp (L : ℕ) : litsBelow L inp = true := rfl
@[simp] theorem litsBelow_attack (L : ℕ) : litsBelow L attack = true := rfl
@[simp] theorem litsBelow_lit (L n : ℕ) : litsBelow L (lit n) = decide (n < L) := rfl
@[simp] theorem litsBelow_ite (L : ℕ) (c a b : PAst) :
    litsBelow L (ite c a b) = (litsBelow L c && litsBelow L a && litsBelow L b) := rfl
@[simp] theorem litsBelow_call (L : ℕ) (f a : PAst) :
    litsBelow L (call f a) = (litsBelow L f && litsBelow L a) := rfl

/-- A finite over-approximation of the programs of size `≤ n` with literals
`< L`.  (Over-approximation is harmless: all we need is that it *contains* the
bounded universe, which makes the latter finite.) -/
def astUniverse : ℕ → ℕ → Finset PAst
  | 0, _ => ∅
  | n + 1, L =>
      insert inp (insert attack
        (((Finset.range L).image lit) ∪
          ((((astUniverse n L) ×ˢ (astUniverse n L)) ×ˢ (astUniverse n L)).image
            (fun p => ite p.1.1 p.1.2 p.2)) ∪
          (((astUniverse n L) ×ˢ (astUniverse n L)).image (fun p => call p.1 p.2))))

/-- **The bounded code universe is finite.**  Every program of size `≤ n` whose
literals are `< L` occurs in the finite set `astUniverse n L`. -/
theorem mem_astUniverse (L : ℕ) :
    ∀ (n : ℕ) (t : PAst), size t ≤ n → litsBelow L t = true → t ∈ astUniverse n L := by
  intro n
  induction n with
  | zero =>
      intro t ht _
      exact absurd ht (by simpa using Nat.not_le.2 (size_pos t))
  | succ n ih =>
      intro t ht hl
      cases t with
      | inp => simp [astUniverse]
      | attack => simp [astUniverse]
      | lit m =>
          have hm : m < L := by simpa using hl
          simp only [astUniverse, Finset.mem_insert]
          refine Or.inr (Or.inr ?_)
          refine Finset.mem_union_left _ (Finset.mem_union_left _ ?_)
          exact Finset.mem_image.2 ⟨m, Finset.mem_range.2 hm, rfl⟩
      | ite c a b =>
          simp only [size_ite] at ht
          simp only [litsBelow_ite, Bool.and_eq_true] at hl
          obtain ⟨⟨hc, ha⟩, hb⟩ := hl
          have hcs : size c ≤ n := by omega
          have has : size a ≤ n := by omega
          have hbs : size b ≤ n := by omega
          simp only [astUniverse, Finset.mem_insert]
          refine Or.inr (Or.inr ?_)
          refine Finset.mem_union_left _ (Finset.mem_union_right _ ?_)
          refine Finset.mem_image.2 ⟨((c, a), b), ?_, rfl⟩
          simp only [Finset.mem_product]
          exact ⟨⟨ih c hcs hc, ih a has ha⟩, ih b hbs hb⟩
      | call f a =>
          simp only [size_call] at ht
          simp only [litsBelow_call, Bool.and_eq_true] at hl
          obtain ⟨hf, ha⟩ := hl
          have hfs : size f ≤ n := by omega
          have has : size a ≤ n := by omega
          simp only [astUniverse, Finset.mem_insert]
          refine Or.inr (Or.inr (Finset.mem_union_right _ ?_))
          refine Finset.mem_image.2 ⟨(f, a), ?_, rfl⟩
          simp only [Finset.mem_product]
          exact ⟨ih f hfs hf, ih a has ha⟩

/-- The immune system's whitelist for the bounded universe: every harmless
program of size `≤ N` with literals `< L`. -/
def BoundedOk (N L : ℕ) (t : PAst) : Prop :=
  size t ≤ N ∧ litsBelow L t = true ∧ run t = false

instance (N L : ℕ) : DecidablePred (BoundedOk N L) := fun t => by
  unfold BoundedOk; infer_instance

def boundedWhitelist (N L : ℕ) : Finset PAst := (astUniverse N L).filter (BoundedOk N L)

theorem mem_boundedWhitelist {N L : ℕ} {t : PAst} :
    t ∈ boundedWhitelist N L ↔ size t ≤ N ∧ litsBelow L t = true ∧ run t = false := by
  unfold boundedWhitelist
  constructor
  · intro h; exact (Finset.mem_filter.1 h).2
  · intro h
    exact Finset.mem_filter.2 ⟨mem_astUniverse L N t h.1 h.2.1, h⟩

/-- **Perfect immunity on a bounded universe.**  The bounded whitelist contains
the trusted baseline, contains *only* harmless programs (so by Part IV no
adversary, however unknown or self-modifying, ever triggers the forbidden
action), and rejects *no* harmless program of the universe: zero false
positives. -/
theorem bounded_perfect_immunity {N L : ℕ} (hN : 1 ≤ N) (hL : 1 ≤ L) :
    lit 0 ∈ boundedWhitelist N L ∧
      (∀ t ∈ boundedWhitelist N L, ¬ malicious t) ∧
      (∀ t : PAst, size t ≤ N → litsBelow L t = true → ¬ malicious t →
        t ∈ boundedWhitelist N L) ∧
      (∀ (adv : ℕ → PAst → PAst) (k : ℕ),
        ¬ malicious (trace (boundedWhitelist N L) (lit 0) adv k)) := by
  have hbase : lit 0 ∈ boundedWhitelist N L := by
    refine mem_boundedWhitelist.2 ⟨by simpa using hN, by simpa using hL, rfl⟩
  have hsafe : ∀ t ∈ boundedWhitelist N L, ¬ malicious t := by
    intro t ht
    have := (mem_boundedWhitelist.1 ht).2.2
    unfold malicious
    simp [this]
  refine ⟨hbase, hsafe, ?_, ?_⟩
  · intro t hs hlit hmal
    refine mem_boundedWhitelist.2 ⟨hs, hlit, ?_⟩
    unfold malicious at hmal
    simpa using hmal
  · intro adv k
    exact neutralization hbase hsafe adv k

/-- All padded variants have literals `< 2`. -/
theorem litsBelow_pad {L : ℕ} (hL : 2 ≤ L) (l : List Bool) : litsBelow L (pad l) = true := by
  induction l with
  | nil => simp [pad]; omega
  | cons b bs ih =>
      cases b <;> simp [pad, ih] <;> omega

/-- **The price of perfect immunity: exponential memory.**  Whenever the size
bound `N` admits the `n`-bit family of behaviourally trivial programs, the
bounded whitelist has at least `2 ^ n` entries.  Perfect immunity on a universe
of size bound `N` therefore costs about `2 ^ (N / 3)` attestation tags. -/
theorem bounded_immunity_memory_lower_bound {N L n : ℕ} (hL : 2 ≤ L) (hN : 3 * n + 1 ≤ N) :
    2 ^ n ≤ (boundedWhitelist N L).card := by
  refine attestation_memory_lower_bound (S := boundedWhitelist N L) (n := n) ?_
  intro t ht
  unfold padFamily at ht
  simp only [Finset.mem_image, Finset.mem_univ, true_and] at ht
  obtain ⟨v, rfl⟩ := ht
  refine mem_boundedWhitelist.2 ⟨?_, litsBelow_pad hL _, ?_⟩
  · rw [size_pad]
    simp only [List.length_ofFn]
    omega
  · unfold run
    exact effect_pad _ _

/-- **The bounded-universe trade-off, in one statement.**  On every bounded code
universe the immune system is *perfect* — total containment together with zero
false positives — and every such immune system needs exponentially many
attestation tags.  Letting `N → ∞` recovers the impossibility results of
Parts III, V and VII. -/
theorem bounded_immunity_tradeoff {N L n : ℕ} (hL : 2 ≤ L) (hN : 3 * n + 1 ≤ N) :
    (∀ (adv : ℕ → PAst → PAst) (k : ℕ),
        ¬ malicious (trace (boundedWhitelist N L) (lit 0) adv k)) ∧
      (∀ t : PAst, size t ≤ N → litsBelow L t = true → ¬ malicious t →
        t ∈ boundedWhitelist N L) ∧
      2 ^ n ≤ (boundedWhitelist N L).card := by
  have h1 : 1 ≤ N := by omega
  have h2 : 1 ≤ L := by omega
  obtain ⟨_, _, hfp, hcont⟩ := bounded_perfect_immunity (N := N) (L := L) h1 h2
  exact ⟨hcont, hfp, bounded_immunity_memory_lower_bound hL hN⟩

end PAst
end ImmuneSystem