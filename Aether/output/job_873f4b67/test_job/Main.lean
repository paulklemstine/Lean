import Mathlib

/-! # Tropical Firewall Determinism

In a black-hole firewall modeled as a tropical variety, determinism
is restored by the absence of additive inverses.
-/

theorem tropical_firewall_determinism
    {R : Type*} [LinearOrder R]
    (a b c : R) (h : max a b = max a c) (hgt : a < max a b) :
    b = c := by
  sorry
