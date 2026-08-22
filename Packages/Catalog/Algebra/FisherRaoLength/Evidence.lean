/-
# Numerical evidence for the Fisher–Rao length bounds

All definitions use `Float`; these are exploratory `#eval` computations, not
proofs.  The verified statements live in `Core.lean`.
-/
namespace FisherRaoEvidence

def sq (x : Float) : Float := x * x
def p (t : Float) : Array Float := #[0.5 + 0.2 * t.sin, 0.3 - 0.05 * t.sin, 0.2 - 0.15 * t.sin]
def v (t : Float) : Array Float := #[0.2 * t.cos, -0.05 * t.cos, -0.15 * t.cos]
def speed (t : Float) : Float :=
  ((List.range 3).foldl (fun acc i => acc + sq ((v t)[i]!) / (p t)[i]!) 0.0).sqrt
def len (a b : Float) (n : Nat) : Float :=
  let h := (b - a) / n.toFloat
  (List.range n).foldl (fun acc k => acc + h * speed (a + (k.toFloat + 0.5) * h)) 0.0
def l1 (a b : Float) : Float :=
  (List.range 3).foldl (fun acc i => acc + ((p b)[i]! - (p a)[i]!).abs) 0.0
#eval (l1 0.0 0.5, len 0.0 0.5 20000)
#eval (l1 0.0 1.5, len 0.0 1.5 20000)
#eval (l1 0.3 1.2, len 0.3 1.2 20000)

def p2 (r t : Float) : Array Float := #[(1 + r * t.sin)/2, (1 - r * t.sin)/2]
def v2 (r t : Float) : Array Float := #[r * t.cos/2, -(r * t.cos)/2]
def speed2 (r t : Float) : Float :=
  ((List.range 2).foldl (fun acc i => acc + sq ((v2 r t)[i]!) / (p2 r t)[i]!) 0.0).sqrt
def len2 (r : Float) (n : Nat) : Float :=
  let b := 3.14159265358979323846 / 2
  let h := b / n.toFloat
  (List.range n).foldl (fun acc k => acc + h * speed2 r ((k.toFloat + 0.5) * h)) 0.0
#eval (len2 0.01 20000, Float.asin 0.01, Float.asin 0.01 / 0.01)
#eval (len2 0.1 20000, Float.asin 0.1, Float.asin 0.1 / 0.1)
#eval (len2 0.5 20000, Float.asin 0.5, Float.asin 0.5 / 0.5)
#eval (len2 0.9 20000, Float.asin 0.9, Float.asin 0.9 / 0.9)
-- chord bound check: chord <= len/2
def chord (a b : Float) : Float :=
  ((List.range 3).foldl (fun acc i => acc + sq ((p b)[i]!.sqrt - (p a)[i]!.sqrt)) 0.0).sqrt
#eval (chord 0.0 0.5, len 0.0 0.5 20000 / 2)
#eval (chord 0.0 1.5, len 0.0 1.5 20000 / 2)

end FisherRaoEvidence