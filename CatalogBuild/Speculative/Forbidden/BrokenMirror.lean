/-! # CatalogBuild.Speculative.Forbidden.BrokenMirror

Auto-generated from theorem catalog database.
Domain: Speculative/Forbidden
Declarations: 9
-/

import Mathlib

noncomputable section

def Mirror.fixedPoints {α : Type*} (m : Mirror α) : Set α :=
  {x | m.reflect x = x}

/-- The set of "shattered" points — those moved by the mirror -/

def Mirror.shatteredPoints {α : Type*} (m : Mirror α) : Set α :=
  {x | m.reflect x ≠ x}

/-
PROBLEM
Every involution on a finite type of odd cardinality must have a fixed point.
    This is the "Broken Mirror Theorem": you cannot have a perfect reflection
    without at least one point that maps to itself.

PROVIDED SOLUTION
The shattered (non-fixed) points pair up: if reflect(x) ≠ x, then reflect(x) is also shattered, and they form a pair {x, reflect(x)}. Since the involution is its own inverse, these pairs partition the shattered points, so there are an even number of shattered points. If the total number of elements is odd, the number of fixed points = total - shattered must be odd, hence at least 1.
-/

theorem broken_mirror_odd_fixed_point {α : Type*} [Fintype α] [DecidableEq α]
    (m : Mirror α) (h_odd : Odd (Fintype.card α)) :
    ∃ x, m.reflect x = x := by
  by_contra! h_contra;
  -- Since the shattered (non-fixed) points pair up, we can partition the shattered points into pairs.
  obtain ⟨S, hS_partition⟩ : ∃ S : Finset (Finset α), (∀ s ∈ S, s.card = 2) ∧ (∀ s ∈ S, ∀ t ∈ S, s ≠ t → Disjoint s t) ∧ (∀ x, x ∈ Finset.biUnion S id ↔ m.reflect x ≠ x) := by
    refine' ⟨ Finset.image ( fun x => { x, m.reflect x } ) Finset.univ, _, _, _ ⟩ <;> simp_all +decide [ Finset.disjoint_left ];
    · exact fun x => Finset.card_pair ( Ne.symm ( h_contra x ) );
    · simp +contextual [ Finset.Subset.antisymm_iff, Finset.subset_iff ];
      intro a b h; have := m.involution a; have := m.involution b; aesop;
  have h_card_even : Even (Finset.card (Finset.biUnion S id)) := by
    rw [ Finset.card_biUnion ] <;> aesop;
  simp_all +decide [ Finset.ext_iff ];
  exact absurd h_card_even ( by rw [ show ( S.biUnion id : Finset α ) = Finset.univ from Finset.eq_univ_of_forall fun x => by obtain ⟨ s, hs₁, hs₂ ⟩ := hS_partition.2.2 x; exact Finset.mem_biUnion.2 ⟨ s, hs₁, hs₂ ⟩ ] ; simpa using h_odd )

/-
PROBLEM
The shattered points always come in pairs (each paired with its image)

PROVIDED SOLUTION
The shattered points pair up under the involution: if reflect(x) ≠ x, then {x, reflect(x)} is a pair of distinct shattered points. The involution restricted to shattered points is a fixed-point-free involution, which means shattered points come in pairs, giving an even count.
-/

theorem mirror_shattered_even {α : Type*} [Fintype α] [DecidableEq α]
    (m : Mirror α) :
    Even (Finset.card (Finset.univ.filter (fun x => m.reflect x ≠ x))) := by
  -- The set of shattered points can be partitioned into pairs {x, m.reflect x} where x ≠ m.reflect x.
  have h_partition : ∃ S : Finset (Finset α), (∀ s ∈ S, s.card = 2) ∧ (∀ s ∈ S, ∀ t ∈ S, s ≠ t → Disjoint s t) ∧ (Finset.filter (fun x => m.reflect x ≠ x) Finset.univ) = Finset.biUnion S id := by
    refine' ⟨ Finset.image ( fun x => { x, m.reflect x } ) ( Finset.filter ( fun x => m.reflect x ≠ x ) Finset.univ ), _, _, _ ⟩ <;> simp +contextual;
    · exact fun x hx => Finset.card_pair ( Ne.symm hx );
    · simp +contextual [ Finset.Subset.antisymm_iff, Finset.subset_iff ];
      intro a ha b hb hab; have := m.involution a; have := m.involution b; aesop;
    · ext x; simp +decide [ eq_comm ] ;
      exact ⟨ fun hx => ⟨ x, hx, Or.inl rfl ⟩, fun ⟨ a, ha, hx ⟩ => hx.elim ( fun hx => hx.symm ▸ ha ) fun hx => hx.symm ▸ by have := m.involution a; aesop ⟩;
  obtain ⟨ S, hS₁, hS₂, hS₃ ⟩ := h_partition; rw [ hS₃, Finset.card_biUnion ] ; aesop;
  exact fun s hs t ht hst => hS₂ s hs t ht hst

/-! ## §2: The Diagonal Shattering — Cantor's Broken Mirror -/

/-
PROBLEM
Cantor's theorem as a "broken mirror": no function can perfectly reflect
    a set into its power set. The mirror is always incomplete.

PROVIDED SOLUTION
The diagonal function d(a,b) = (a = b) maps to Prop not Set α, but we need to show it's not surjective to (α → Prop). Consider the "anti-diagonal" set S = {a | ¬(a = a)} = ∅. Actually this is always false so S = ∅. But the range of (fun a b => a = b) maps each a to the singleton predicate (· = a). So we need a predicate not of this form. The predicate (fun b => True) works: if it equals (fun b => a = b) for some a, then True = (a = b) for all b, but picking b ≠ a gives True = False. Actually we need to handle the case α is empty. If α is empty, then Surjective means ∀ t : α → Prop, ∃ a, ... but there are no a's, and there is the empty function as target, so this might be vacuously false. Let me think... if α is empty, then (α → Prop) has exactly one element (the empty function), and there are no elements in α to map from, so the function has empty range, and it's not surjective. Use Cantor-style diagonal or handle cases.
-/

theorem cantor_broken_mirror (α : Type*) : ¬ Surjective (fun (a : α) (b : α) => a = b) := by
  by_contra h_surjective
  obtain ⟨x, hx⟩ : ∃ x : α → Prop, ¬∃ a : α, x = fun b => a = b := by
    by_cases h : Nonempty α <;> simp_all +decide [ funext_iff ];
    exact ⟨ fun _ => False, fun a => ⟨ a, by simp +decide ⟩ ⟩;
  obtain ⟨ a, ha ⟩ := h_surjective x; exact hx ⟨ a, ha.symm ⟩ ;

/-
PROBLEM
The deeper version: no surjection from any type to its function space to Bool

PROVIDED SOLUTION
Classic Cantor diagonal: define g(x) = !(f(x)(x)). Then g cannot be in the range of f, since f(a) = g would mean f(a)(a) = g(a) = !(f(a)(a)), contradiction.
-/

theorem diagonal_shattering (α : Type*) (f : α → (α → Bool)) : ¬ Surjective f := by
  intro h;
  -- Define a new function g that differs from each f(a) at least at one point.
  set g : α → Bool := fun a => if f a a = Bool.true then Bool.false else Bool.true;
  cases' h g with a ha ; replace ha := congr_fun ha a ; aesop

/-! ## §3: Interval Fixed Points — The Mirror Must Touch Ground -/

/-
PROBLEM
The discrete intermediate value theorem for ℤ-valued functions:
    if g(0) > 0 and g(n) < 0, then g has a zero in {0,...,n}.
    A discrete version of the IVT / Brouwer.

PROVIDED SOLUTION
By strong induction on n. g(0) > 0 and g(n) < 0, and consecutive values differ by at most 1. So g must cross zero somewhere. Use well-founded induction: consider the smallest k in {0,...,n} with g(k) ≤ 0. Then g(k-1) > 0 and g(k) ≤ 0. Since |g(k) - g(k-1)| ≤ 1 and g(k-1) ≥ 1, g(k) ≥ 0. So g(k) = 0.
-/

theorem discrete_ivt (g : ℤ → ℤ) (n : ℕ) (hn : 0 < n)
    (h0 : 0 < g 0) (hn' : g n < 0)
    (h_step : ∀ k : ℤ, |g (k + 1) - g k| ≤ 1) :
    ∃ k : ℤ, 0 ≤ k ∧ k ≤ n ∧ g k = 0 := by
  -- By induction on $k$, we can show that if $g(k) > 0$, then $g(k+1) \geq 0$.
  by_contra h_contra; push_neg at h_contra; (
  -- By induction on $k$, we can show that $g(k) > 0$ for all $k \in \{0, 1, \ldots, n\}$.
  have h_pos : ∀ k ∈ Finset.range (n + 1), 0 < g k := by
    intro k hk; induction' k with k ih <;> norm_num at *;
    · grind;
    · exact lt_of_le_of_ne ( by linarith [ abs_le.mp ( h_step k ), ih ( Nat.le_of_lt hk ) ] ) ( Ne.symm ( h_contra _ ( by linarith ) ( by linarith ) ) );
  linarith [ h_pos n ( Finset.mem_range.mpr ( Nat.lt_succ_self n ) ) ])

/-! ## §4: The Self-Knowledge Impossibility -/

/-
PROBLEM
No decidable predicate can decide its own halting behavior.
    The mirror cannot see itself completely.

PROVIDED SOLUTION
Suppose such halt exists. Define f(n) = !halt(f). Then halt(f) = true ↔ f(0) = halt(f) = true ↔ !halt(f) = true ↔ halt(f) = false, contradiction. Actually more carefully: let f be the constant function (fun _ => !(halt f)). We need to be careful about the self-reference... Actually, define f := (fun _ => true) and (fun _ => false) and derive a contradiction from the condition halt f = true ↔ f 0 = halt f, which becomes halt f = true ↔ true = halt f or halt f = true ↔ false = halt f depending on f. The key is that we can choose f based on halt f. Actually the simplest: instantiate with f = (fun _ => false). Then halt f = true ↔ false = halt f. If halt f = true, then false = true, contradiction. If halt f = false, then halt f = true ↔ false = false ↔ True, so halt f = true, contradiction.
-/

theorem no_perfect_self_mirror :
    ¬ ∃ (halt : (ℕ → Bool) → Bool),
      ∀ f : ℕ → Bool, halt f = true ↔ f 0 = halt f := by
  by_contra h;
  cases' h with halt h; have := h ( fun _ => Bool.true ) ; have := h ( fun _ => Bool.false ) ; simp +decide at *;

/-! ## §5: Symmetry Group Fixed-Point Theorem -/

/-
PROBLEM
A p-group acting on a finite set: the number of fixed points is
    congruent to the total number of elements modulo p.
    We prove the simpler version: if an involution acts on a set,
    the parity of fixed points equals the parity of the total set.

PROVIDED SOLUTION
Fintype.card α = |fixed points| + |non-fixed points|. The non-fixed points come in pairs {x, f(x)} (by the involution property and mirror_shattered_even), so |non-fixed| is even. Therefore Fintype.card α and |fixed points| have the same parity. Use mirror_shattered_even or reason directly: the filter complement has even cardinality, and card = fixed + non-fixed.
-/

theorem involution_parity_fixed {α : Type*} [Fintype α] [DecidableEq α]
    (f : α → α) (hf : ∀ x, f (f x) = x) :
    Even (Fintype.card α) ↔
    Even (Finset.card (Finset.univ.filter (fun x => f x = x))) := by
  -- The shattered points always come in pairs (each paired with its image), so their number is even.
  have h_pair : Even (Finset.card (Finset.filter (fun x => f x ≠ x) Finset.univ)) := by
    convert mirror_shattered_even ⟨ f, hf ⟩ using 1;
  simp_all +decide [ Finset.filter_not, Finset.card_sdiff ];
  grind


end
