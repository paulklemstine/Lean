# Why computational evidence was skipped

The conjecture is settled structurally, not numerically. For any type `T` and
predicate `P : T → Prop`, the dependent product `∀ x : T, P x` is a
subsingleton by proof irrelevance. An equivalence from `T` to that product
therefore forces `T` to be a subsingleton, and a separate argument excludes the
empty type. Thus all cases, finite and infinite, collapse to the equivalence
class of `Unit`.

Small-case enumeration would only illustrate consequences already proved for
all universes, and there is no integer sequence for which an OEIS search would
be mathematically relevant. The formal file nevertheless includes concrete
boundary cases: `Unit` satisfies the equation and `Bool` does not.
