import Mathlib
import Shared.GraphTheory.FractalTruthMetric
import MachineLearning.CantorCompactness
import MachineLearning.CantorSubshiftDimension

/-!
# Closed sets of streams are exactly the sets defined by a prefix language

Fourth cycle.  Cycles 1–3 developed the metric side of the Cantor truth space and the
golden-mean subshift.  This file extracts the structural pattern that all of those proofs
shared: *every metric statement about this space is a statement about prefixes*.

The main theorem is a Galois-style dictionary.

* For an arbitrary family `L : ℕ → Set (List Bool)` of admissible words, the set of streams
  all of whose prefixes are admissible is **closed** (`isClosed_setOf_prefixes`), because each
  condition `prefixOf n x ∈ L n` is clopen (`isClopen_setOf_prefixOf_mem`).
* Conversely a **closed** set of streams is exactly the set of streams whose prefixes are
  prefixes of its own points (`isClosed_eq_setOf_prefixes`).  Consequently two closed sets
  with the same prefix language coincide (`eq_of_image_prefixOf_eq`).

Specialising to the golden-mean subshift recovers, without any new combinatorics, the
statement that it is *cut out by the Fibonacci word list*:
`GoldenMean = {x | ∀ n, prefixOf n x ∈ goldenWords n}`.
-/

namespace FractalTruthCompactness

open FractalTruthMetric Metric

/-! ## Prefixes grow by appending -/

theorem prefixOf_succ_eq_append : ∀ (n : ℕ) (x : Cantor),
    prefixOf (n + 1) x = prefixOf n x ++ [x n]
  | 0, x => rfl
  | (n + 1), x => by
      have ih := prefixOf_succ_eq_append n (shift x)
      rw [prefixOf_succ, ih, prefixOf_succ]
      rfl

theorem prefixOf_isPrefix (n : ℕ) (x : Cantor) : prefixOf n x <+: prefixOf (n + 1) x := by
  rw [prefixOf_succ_eq_append]
  exact ⟨[x n], rfl⟩

/-! ## Prefix conditions are clopen -/

/-- Agreement to depth `n` is exactly equality of depth-`n` prefixes, so a condition on the
depth-`n` prefix is constant on cylinders. -/
theorem prefixOf_eq_of_mem_cylinder {n : ℕ} {x y : Cantor} (h : y ∈ cylinder n x) :
    prefixOf n y = prefixOf n x :=
  (prefixOf_eq_iff_agreeTo n y x).mpr (agreeTo_symm h)

/-- **Any prefix condition is clopen.** -/
theorem isClopen_setOf_prefixOf_mem (n : ℕ) (S : Set (List Bool)) :
    IsClopen {x : Cantor | prefixOf n x ∈ S} := by
  constructor
  · rw [← isOpen_compl_iff, Metric.isOpen_iff]
    intro x hx
    refine ⟨(2 : ℝ) ^ (1 - (n : ℤ)), by positivity, ?_⟩
    intro y hy
    have hcyl : y ∈ cylinder n x := by
      rw [cylinder_eq_ball]; exact hy
    intro hmem
    exact hx (by rw [Set.mem_setOf_eq, ← prefixOf_eq_of_mem_cylinder hcyl]; exact hmem)
  · rw [Metric.isOpen_iff]
    intro x hx
    refine ⟨(2 : ℝ) ^ (1 - (n : ℤ)), by positivity, ?_⟩
    intro y hy
    have hcyl : y ∈ cylinder n x := by
      rw [cylinder_eq_ball]; exact hy
    rw [Set.mem_setOf_eq, prefixOf_eq_of_mem_cylinder hcyl]
    exact hx

/-- **A prefix language always defines a closed set of streams.** -/
theorem isClosed_setOf_prefixes (L : ℕ → Set (List Bool)) :
    IsClosed {x : Cantor | ∀ n, prefixOf n x ∈ L n} := by
  have h : {x : Cantor | ∀ n, prefixOf n x ∈ L n}
      = ⋂ n, {x : Cantor | prefixOf n x ∈ L n} := by
    ext x; simp [Set.mem_iInter]
  rw [h]
  exact isClosed_iInter fun n => (isClopen_setOf_prefixOf_mem n (L n)).1

/-! ## Closed sets are recovered from their prefix language -/

/-- **Closed sets are determined by their prefixes.**  A stream all of whose prefixes occur in
a closed set `X` already belongs to `X`. -/
theorem mem_of_forall_prefixOf_mem_image {X : Set Cantor} (hX : IsClosed X) {x : Cantor}
    (h : ∀ n, prefixOf n x ∈ prefixOf n '' X) : x ∈ X := by
  rw [← hX.closure_eq, Metric.mem_closure_iff]
  intro ε hε
  obtain ⟨n, hn⟩ := exists_two_zpow_lt hε
  obtain ⟨y, hyX, hy⟩ := h n
  refine ⟨y, hyX, ?_⟩
  have hA : AgreeTo n x y := (prefixOf_eq_iff_agreeTo n x y).mp hy.symm
  exact lt_of_le_of_lt ((dist_le_iff_agreeTo x y n).mpr hA) hn

/-- A closed set of streams is exactly the set of streams whose finite prefixes it realises. -/
theorem isClosed_eq_setOf_prefixes {X : Set Cantor} (hX : IsClosed X) :
    X = {x : Cantor | ∀ n, prefixOf n x ∈ prefixOf n '' X} := by
  ext x
  constructor
  · intro hx n
    exact ⟨x, hx, rfl⟩
  · exact mem_of_forall_prefixOf_mem_image hX

/-- **Two closed sets with the same prefix language are equal.** -/
theorem eq_of_image_prefixOf_eq {X Y : Set Cantor} (hX : IsClosed X) (hY : IsClosed Y)
    (h : ∀ n, prefixOf n '' X = prefixOf n '' Y) : X = Y := by
  rw [isClosed_eq_setOf_prefixes hX, isClosed_eq_setOf_prefixes hY]
  ext x
  constructor
  · intro hx n; rw [← h n]; exact hx n
  · intro hx n; rw [h n]; exact hx n

/-- The prefix language of a nonempty set is extendable: every realised word has a realised
one-letter extension. -/
theorem exists_extension_of_mem_image {X : Set Cantor} {n : ℕ} {w : List Bool}
    (hw : w ∈ prefixOf n '' X) : ∃ b : Bool, w ++ [b] ∈ prefixOf (n + 1) '' X := by
  obtain ⟨x, hx, rfl⟩ := hw
  exact ⟨x n, ⟨x, hx, (prefixOf_succ_eq_append n x)⟩⟩

/-- The prefix language is factorial downwards: a realised word of length `n+1` has its
length-`n` prefix realised. -/
theorem take_mem_image_of_mem_image {X : Set Cantor} {n : ℕ} {w : List Bool}
    (hw : w ∈ prefixOf (n + 1) '' X) : w.take n ∈ prefixOf n '' X := by
  obtain ⟨x, hx, rfl⟩ := hw
  refine ⟨x, hx, ?_⟩
  rw [prefixOf_succ_eq_append, List.take_append_of_le_length (by rw [length_prefixOf])]
  simp [length_prefixOf]

/-! ## Application: the golden-mean subshift is cut out by the Fibonacci word lists -/

/-- **The golden-mean subshift is exactly the set of streams whose every prefix is one of the
`fib (n+2)` admissible words.**  This follows from the general dictionary together with the
prefix computation of cycle 1, with no further combinatorics. -/
theorem goldenMean_eq_setOf_prefixes :
    GoldenMean = {x : Cantor | ∀ n, prefixOf n x ∈ goldenWords n} := by
  rw [isClosed_eq_setOf_prefixes isClosed_goldenMean]
  ext x
  constructor
  · intro hx n
    have := hx n
    rw [goldenWords_eq_image_prefixOf n] at this
    exact this
  · intro hx n
    rw [goldenWords_eq_image_prefixOf n]
    exact hx n

/-! ## König's lemma: extendable languages are realised by streams -/

variable (L : ℕ → Set (List Bool))

/-- Reading the last letter of a word obtained by appending one letter. -/
theorem getD_append_singleton {l : List Bool} {n : ℕ} (h : l.length = n) (b : Bool) :
    (l ++ [b]).getD n false = b := by
  subst h
  induction l with
  | nil => rfl
  | cons a t _ => simp

/-- Greedy chain of words obtained by repeatedly using extendability. -/
noncomputable def langChain (h0 : [] ∈ L 0)
    (hext : ∀ n w, w ∈ L n → ∃ b, w ++ [b] ∈ L (n + 1)) : (n : ℕ) → {w : List Bool // w ∈ L n}
  | 0 => ⟨[], h0⟩
  | (n + 1) =>
      let p := langChain h0 hext n
      ⟨p.1 ++ [Classical.choose (hext n p.1 p.2)], Classical.choose_spec (hext n p.1 p.2)⟩

theorem langChain_succ (h0 : [] ∈ L 0)
    (hext : ∀ n w, w ∈ L n → ∃ b, w ++ [b] ∈ L (n + 1)) (n : ℕ) :
    (langChain L h0 hext (n + 1)).1 =
      (langChain L h0 hext n).1 ++
        [Classical.choose (hext n (langChain L h0 hext n).1 (langChain L h0 hext n).2)] := rfl

theorem langChain_length (h0 : [] ∈ L 0)
    (hext : ∀ n w, w ∈ L n → ∃ b, w ++ [b] ∈ L (n + 1)) :
    ∀ n, ((langChain L h0 hext n).1).length = n
  | 0 => rfl
  | (n + 1) => by
      rw [langChain_succ, List.length_append, langChain_length h0 hext n]
      simp

/-- The stream assembled from the greedy chain. -/
noncomputable def langStream (h0 : [] ∈ L 0)
    (hext : ∀ n w, w ∈ L n → ∃ b, w ++ [b] ∈ L (n + 1)) : Cantor :=
  fun k => ((langChain L h0 hext (k + 1)).1).getD k false

theorem prefixOf_langStream (h0 : [] ∈ L 0)
    (hext : ∀ n w, w ∈ L n → ∃ b, w ++ [b] ∈ L (n + 1)) :
    ∀ n, prefixOf n (langStream L h0 hext) = (langChain L h0 hext n).1
  | 0 => rfl
  | (n + 1) => by
      have ih := prefixOf_langStream h0 hext n
      have hlen := langChain_length L h0 hext n
      have hval : langStream L h0 hext n
          = Classical.choose (hext n (langChain L h0 hext n).1 (langChain L h0 hext n).2) := by
        show ((langChain L h0 hext (n + 1)).1).getD n false = _
        rw [langChain_succ]
        exact getD_append_singleton hlen _
      rw [prefixOf_succ_eq_append, ih, hval, langChain_succ]

/-- **König's lemma for the Cantor truth space.**  A language that contains the empty word and
in which every word has a one-letter extension is realised by an infinite stream. -/
theorem exists_stream_of_extendable (h0 : [] ∈ L 0)
    (hext : ∀ n w, w ∈ L n → ∃ b, w ++ [b] ∈ L (n + 1)) :
    ∃ x : Cantor, ∀ n, prefixOf n x ∈ L n := by
  refine ⟨langStream L h0 hext, fun n => ?_⟩
  rw [prefixOf_langStream]
  exact (langChain L h0 hext n).2

/-- Consequently the closed set defined by an extendable language is nonempty (and compact,
being closed in a compact space). -/
theorem nonempty_setOf_prefixes (h0 : [] ∈ L 0)
    (hext : ∀ n w, w ∈ L n → ∃ b, w ++ [b] ∈ L (n + 1)) :
    {x : Cantor | ∀ n, prefixOf n x ∈ L n}.Nonempty :=
  exists_stream_of_extendable L h0 hext

/-! ## The Fibonacci language is extendable -/

/-- Every admissible word extends to a longer admissible word (append `false`). -/
theorem goldenWords_extendable (n : ℕ) (w : List Bool) (hw : w ∈ goldenWords n) :
    w ++ [false] ∈ goldenWords (n + 1) := by
  have hw' : w ∈ prefixOf n '' GoldenMean := by
    rw [goldenWords_eq_image_prefixOf n]; exact hw
  obtain ⟨x, hx, rfl⟩ := hw'
  have hy : trunc n x ∈ GoldenMean := trunc_mem_goldenMean hx n
  have hpre : prefixOf n (trunc n x) = prefixOf n x :=
    (prefixOf_eq_iff_agreeTo n (trunc n x) x).mpr (agreeTo_symm (agreeTo_trunc n x))
  have hlast : (trunc n x) n = false := by simp [trunc]
  have happ : prefixOf (n + 1) (trunc n x) = prefixOf n x ++ [false] := by
    rw [prefixOf_succ_eq_append, hpre, hlast]
  have hmem := prefixOf_mem_goldenWords (n + 1) hy
  rwa [happ] at hmem

/-- The Fibonacci language realises the subshift through König's lemma as well. -/
theorem exists_goldenMean_stream :
    ∃ x : Cantor, ∀ n, prefixOf n x ∈ goldenWords n := by
  obtain ⟨x, hx⟩ := exists_stream_of_extendable (fun n => (↑(goldenWords n) : Set (List Bool)))
    (by simp [goldenWords_zero])
    (fun n w hw => ⟨false, by simpa using goldenWords_extendable n w (by simpa using hw)⟩)
  exact ⟨x, fun n => by simpa using hx n⟩

end FractalTruthCompactness