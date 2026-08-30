# Computational evidence

Short, targeted numerical experiments performed before and during the Lean formalisation.
All computations below were run inside Lean 4 (`#eval`, exact rational arithmetic); the
outputs are reproduced verbatim.  They are *evidence*, not proof — every claim that appears
in the `.lean` files is proved there without `sorry`.

## 1. The dyadic scale `powHalf`

The clopen-cut construction uses the surreal dyadic scale `powHalf n = 2^{-n}`.  Modelled in
`ℚ`:

```lean
#eval (List.range 8).map (fun n => ((1:ℚ)/2^n))
-- [1, 1/2, 1/4, 1/8, 1/16, 1/32, 1/64, 1/128]

#eval (List.range 8).all (fun n => (1:ℚ)/2^(n+1) + 1/2^(n+1) = 1/2^n)
-- true          (the identity `d·h_{n+1} + d·h_{n+1} = d·h_n` used throughout)

#eval (List.range 20).all (fun n => n ≤ 2^n)
-- true          (why "doubling stays inside a monad")
```

## 2. Counterexample hunt: the argument must fail over `ℚ` and `ℝ`

The whole programme rests on the failure of countable coinitiality of the positive
elements.  Over an archimedean field the analogous statement is *false*, and the search for
a positive element below all of `2^{-n}` finds nothing:

```lean
#eval (List.range 6).map (fun k => ((1:ℚ)/(k+1),
        (List.range 40).all (fun n => (1:ℚ)/(k+1) < 1/2^n)))
-- [(1, false), (1/2, false), (1/3, false), (1/4, false), (1/5, false), (1/6, false)]
```

So no rational candidate survives; consistent with `ℝ` and `ℚ` being first countable and
connected.  This isolates *non-archimedean-ness* (equivalently, the availability of Conway
cuts over arbitrary index sets) as the only possible engine of the theorems, and it is
exactly the ingredient `Surreal.cut` supplies.

## 3. Toy non-archimedean model: lexicographic `ℚ × ℚ`

Before formalising in `Surreal`, all four structural claims were checked in the smallest
non-archimedean ordered group, `ℚ × ℚ` ordered lexicographically:

```lean
def ltLex (a b : ℚ × ℚ) : Bool := a.1 < b.1 || (a.1 == b.1 && a.2 < b.2)
def smul (n : ℕ) (a : ℚ × ℚ) : ℚ × ℚ := (n * a.1, n * a.2)

#eval (List.range 200).all (fun n => ltLex (smul n (0,1)) (1,0))      -- true
#eval (List.range 30).all  (fun n => ltLex (0,1) ((1:ℚ)/2^n, 0))      -- true
#eval (List.range 10).all  (fun k => ltLex (0,(k:ℚ)) (1,0)
                                     && ltLex (0,0) (0,(k:ℚ)+1))       -- true
```

Reading of the data:

* line 1 — `(0,1)` is positive yet infinitesimal relative to `(1,0)`: the *monad* of `0` at
  scale `(1,0)` is non-trivial.  This is the model prediction that
  `Surreal.monad` is a genuine (non-singleton) clopen set.
* line 2 — a positive element strictly below a whole sequence of positive elements exists:
  the model prediction of `Surreal.exists_pos_lt_seq`.
* line 3 — the monad is closed under adding further infinitesimals and has no largest
  element: the model prediction behind `smallerPart_no_max` and hence openness.

Every prediction of the toy model was subsequently proved for `Surreal` itself, where the
Conway cut replaces the ad-hoc second coordinate and allows *arbitrarily indexed* families,
not just sequences (`Surreal.exists_pos_lt_family`).

## 4. No OEIS sequence

No integer sequence is attached to these results (the objects are topological/order
theoretic), so no OEIS search was performed.
