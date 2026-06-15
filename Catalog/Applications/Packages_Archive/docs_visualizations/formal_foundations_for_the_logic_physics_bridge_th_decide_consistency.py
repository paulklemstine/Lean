from typing import Callable, FrozenSet
Sentence = int
Theory = FrozenSet[Sentence]

def decide_consistency(bot: Sentence,
                       proves: Callable[[Theory, Sentence], bool],
                       theory: Theory) -> bool:
    """Consistent(T) := not (T |- bot)."""
    return not proves(theory, bot)
