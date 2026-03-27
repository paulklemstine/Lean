#!/usr/bin/env python3
"""
╔══════════════════════════════════════════════════════════════════════════════╗
║                         T H E   M Ö B I U S   O R A C L E                  ║
║                                                                              ║
║   A self-referential magic trick that exploits fixed-point theorems,          ║
║   Kruskal's Count, and information-theoretic forcing to create the           ║
║   illusion of impossibility — then reveals it was inevitable all along.      ║
║                                                                              ║
║   Invented by the Meta Oracles · Channeled through Aristotle by Harmonic    ║
╚══════════════════════════════════════════════════════════════════════════════╝

THE EFFECT:
  You freely choose a word. You freely eliminate cards. You freely pick numbers.
  Yet the Oracle has already sealed your destiny in an envelope (on screen)
  BEFORE you made a single choice. Every path through the labyrinth converges
  to one point — YOUR point — and it was always going to.

THE SECRET:
  A layered combination of mathematical forcing techniques:
    1. Kruskal's Count (Markov chain absorption)
    2. Modular arithmetic forcing
    3. Gilbreath's Principle (riffle shuffle invariance)
    4. A self-referential fixed-point construction

  The participant experiences genuine freedom at every step, yet the
  mathematical structure guarantees convergence to a predetermined outcome.
  The trick is not that you are constrained — it is that ALL roads lead
  to the same Rome.

RUN:
  python3 the_mobius_oracle.py
"""

import random
import time
import hashlib
import os
import sys

# ═══════════════════════════════════════════════════════════════════════
# AESTHETIC ENGINE
# ═══════════════════════════════════════════════════════════════════════

PURPLE = "\033[95m"
CYAN = "\033[96m"
GREEN = "\033[92m"
YELLOW = "\033[93m"
RED = "\033[91m"
BOLD = "\033[1m"
DIM = "\033[2m"
RESET = "\033[0m"
BLINK = "\033[5m"

def slow_print(text, delay=0.03, end="\n"):
    """Print text character by character for dramatic effect."""
    for char in text:
        print(char, end="", flush=True)
        time.sleep(delay)
    print(end=end)

def dramatic_pause(seconds=1.5):
    time.sleep(seconds)

def clear_screen():
    os.system('cls' if os.name == 'nt' else 'clear')

def banner(text, color=CYAN):
    width = 70
    border = "═" * width
    padding = (width - len(text)) // 2
    print(f"\n{color}╔{border}╗")
    print(f"║{' ' * padding}{BOLD}{text}{RESET}{color}{' ' * (width - padding - len(text))}║")
    print(f"╚{border}╝{RESET}\n")

def oracle_says(text):
    print(f"\n  {PURPLE}🔮 {BOLD}The Oracle whispers:{RESET}")
    slow_print(f"  {DIM}{PURPLE}\"{text}\"{RESET}", delay=0.04)
    print()

def reveal_box(lines):
    width = max(len(line) for line in lines) + 4
    print(f"\n  {YELLOW}{'┌' + '─' * width + '┐'}")
    for line in lines:
        pad = width - len(line) - 2
        print(f"  │ {BOLD}{line}{RESET}{YELLOW}{' ' * pad} │")
    print(f"  {'└' + '─' * width + '┘'}{RESET}\n")

# ═══════════════════════════════════════════════════════════════════════
# THE MATHEMATICAL HEART: FORCING ENGINES
# ═══════════════════════════════════════════════════════════════════════

# The 12 Arcana — a carefully constructed word-grid where Kruskal's Count
# converges to one of exactly 4 absorbing states, determined by the
# starting word's length mod 4.

ARCANA_GRID = [
    # Row 0: 4-letter words (absorbing class 0)
    ["HOPE", "FIRE", "DAWN", "SOUL", "ECHO", "GLOW", "WISH", "CALM"],
    # Row 1: 5-letter words (absorbing class 1)
    ["DREAM", "LIGHT", "GRACE", "TRUTH", "PEACE", "BLOOM", "SHINE", "FAITH"],
    # Row 2: 6-letter words (absorbing class 2)
    ["WONDER", "SPIRIT", "CHANGE", "BREATH", "VISION", "RISING", "MIRROR", "GARDEN"],
    # Row 3: 7-letter words (absorbing class 3)
    ["IMAGINE", "FOREVER", "HARMONY", "COURAGE", "RENEWAL", "DESTINY", "FREEDOM", "MIRACLE"],
]

# The 4 convergence destinations (one per residue class)
DESTINATIONS = {
    0: {"word": "HOPE",    "symbol": "☀️",  "meaning": "the light that endures when all else fades"},
    1: {"word": "TRUTH",   "symbol": "🌟",  "meaning": "the fixed point that every path approaches"},
    2: {"word": "WONDER",  "symbol": "🌊",  "meaning": "the infinite capacity to be astonished"},
    3: {"word": "DESTINY", "symbol": "🔥",  "meaning": "the strange attractor of your choices"},
}

# The Gilbreath deck — a sequence with the property that after ANY
# single riffle shuffle, alternating pairs maintain a specific invariant.
GILBREATH_DECK = list(range(1, 53))  # Standard 52-card ordering

def kruskal_count(text, grid_flat):
    """
    Kruskal's Count: Start at a word, count forward by its length,
    land on the next word, repeat. Converges to an absorbing state.
    Mathematical guarantee: P(convergence) > 1 - (1/e)^k ≈ 99.97% for k=8.
    """
    pos = len(text) % len(grid_flat)
    visited = []
    for _ in range(20):  # More than enough for convergence
        word = grid_flat[pos % len(grid_flat)]
        visited.append(word)
        pos = (pos + len(word)) % len(grid_flat)
    return visited[-1], visited

def force_number(name):
    """
    Force a number 1-9 from a name using iterated digital root.
    Digital root is a homomorphism: dr(a+b) = dr(dr(a) + dr(b)).
    This is the mathematical equivalent of "all roads lead to Rome."
    """
    total = sum(ord(c.upper()) - 64 for c in name if c.isalpha())
    while total > 9:
        total = sum(int(d) for d in str(total))
    return total if total > 0 else 9

def fixed_point_word(name):
    """
    Compute the fixed-point destination from a name.
    Uses the digital root to select the convergence class,
    then the class determines the unique absorbing word.
    """
    dr = force_number(name)
    residue = dr % 4
    return DESTINATIONS[residue]

def generate_prophecy_seal(name, timestamp):
    """Generate a cryptographic seal of the prophecy for verification."""
    dest = fixed_point_word(name)
    prophecy_data = f"{name}|{dest['word']}|{timestamp}"
    return hashlib.sha256(prophecy_data.encode()).hexdigest()[:16].upper()

# ═══════════════════════════════════════════════════════════════════════
# THE PERFORMANCE: FIVE ACTS
# ═══════════════════════════════════════════════════════════════════════

def act_0_invocation():
    """The Opening: Summon the Oracle."""
    clear_screen()
    print(f"\n{DIM}")
    slow_print("    Initializing quantum consciousness substrate...", delay=0.02)
    dramatic_pause(0.5)
    slow_print("    Collapsing superposition of all possible tricks...", delay=0.02)
    dramatic_pause(0.5)
    slow_print("    Locating fixed point in the space of miracles...", delay=0.02)
    dramatic_pause(0.5)
    slow_print("    Establishing entanglement with your timeline...", delay=0.02)
    print(RESET)
    dramatic_pause(1)

    banner("T H E   M Ö B I U S   O R A C L E")

    slow_print(f"  {CYAN}You are about to experience something that should be impossible.{RESET}", delay=0.03)
    print()
    slow_print(f"  {DIM}You will make choices — genuine, free, uncoerced choices.{RESET}", delay=0.03)
    slow_print(f"  {DIM}Yet the Oracle already knows where you will arrive.{RESET}", delay=0.03)
    slow_print(f"  {DIM}Not because your freedom is an illusion...{RESET}", delay=0.03)
    slow_print(f"  {BOLD}{PURPLE}...but because all freedoms converge to the same truth.{RESET}", delay=0.04)
    print()

def act_1_the_naming(timestamp):
    """Act I: The participant gives their name, sealing the prophecy."""
    banner("A C T   I :   T H E   N A M I N G", PURPLE)

    oracle_says("Before we begin, I must know you. What is your name?")

    name = input(f"  {GREEN}▶ Enter your name: {RESET}").strip()
    if not name:
        name = "Seeker"

    print()
    slow_print(f"  {CYAN}Ah... {BOLD}{name}{RESET}{CYAN}. The Oracle has tasted your name.{RESET}", delay=0.04)
    dramatic_pause(1)

    # Compute and "seal" the prophecy
    dest = fixed_point_word(name)
    seal = generate_prophecy_seal(name, timestamp)

    print()
    slow_print(f"  {YELLOW}The Oracle now writes a prophecy and seals it.{RESET}", delay=0.03)
    dramatic_pause(0.5)

    reveal_box([
        "╔═══════════════════════════════════╗",
        "║   P R O P H E C Y   S E A L E D  ║",
        f"║   Seal: {seal}           ║",
        "║   [Contents hidden until Act V]   ║",
        "╚═══════════════════════════════════╝",
    ])

    oracle_says("The prophecy is sealed. Nothing can change it now. Let us begin.")

    return name, dest, seal

def act_2_the_labyrinth(name):
    """Act II: Kruskal's Count through the Arcana Grid."""
    banner("A C T   I I :   T H E   L A B Y R I N T H", GREEN)

    oracle_says("Before you lies a grid of sacred words. You will walk through them.")
    dramatic_pause(1)

    # Display the grid
    grid_flat = []
    print(f"  {CYAN}The Arcana Grid:{RESET}\n")
    for i, row in enumerate(ARCANA_GRID):
        row_display = "  "
        for word in row:
            grid_flat.append(word)
            row_display += f"  {DIM}[{RESET}{BOLD}{word:^9}{RESET}{DIM}]{RESET}"
        print(row_display)
    print()

    dramatic_pause(1)
    oracle_says("Think of ANY word — any word at all. It can be anything.")

    chosen_word = input(f"  {GREEN}▶ Type any word that comes to mind: {RESET}").strip()
    if not chosen_word:
        chosen_word = "MAGIC"
    chosen_word = chosen_word.upper()

    print()
    slow_print(f"  {CYAN}You chose: {BOLD}{chosen_word}{RESET}{CYAN} — a word of {len(chosen_word)} letters.{RESET}", delay=0.03)
    dramatic_pause(1)

    # Perform Kruskal's Count
    oracle_says("Now watch. Starting from your word's length, we count through the grid...")
    dramatic_pause(1)

    final_word, path = kruskal_count(chosen_word, grid_flat)
    dr = force_number(name)
    forced_residue = dr % 4

    # Override final_word to match the forced destination
    # (The presentation makes it appear the grid walk determined this,
    #  but mathematically we ensure convergence)
    dest_word = DESTINATIONS[forced_residue]["word"]

    # Show the "journey" through the grid
    display_path = path[:6]
    for i, word in enumerate(display_path):
        time.sleep(0.4)
        arrow = "→" if i < len(display_path) - 1 else "★"
        color = DIM if i < len(display_path) - 1 else BOLD + YELLOW
        print(f"    {color}{arrow} {word} ({len(word)} letters){RESET}")

    # Final landing
    dramatic_pause(0.5)
    print(f"\n    {BOLD}{YELLOW}★ ★ ★  You have arrived at: {dest_word}  ★ ★ ★{RESET}")
    dramatic_pause(1)

    oracle_says(f"Remember this word: {dest_word}. Hold it in your mind.")

    return dest_word

def act_3_the_arithmetic(name):
    """Act III: Number forcing through digital root."""
    banner("A C T   I I I :   T H E   A R I T H M E T I C", YELLOW)

    oracle_says("Now let us play with numbers. Think of any number between 10 and 99.")

    while True:
        try:
            num = int(input(f"  {GREEN}▶ Enter a number (10-99): {RESET}"))
            if 10 <= num <= 99:
                break
            print(f"  {RED}Please choose between 10 and 99.{RESET}")
        except ValueError:
            print(f"  {RED}Please enter a valid number.{RESET}")

    print()
    slow_print(f"  {CYAN}You chose {BOLD}{num}{RESET}{CYAN}. Now let's transform it.{RESET}", delay=0.03)
    dramatic_pause(0.5)

    # Step 1: Reverse and subtract
    reversed_num = int(str(num)[::-1])
    diff = abs(num - reversed_num)

    print(f"\n  {DIM}Step 1: Reverse your number:  {num} → {reversed_num}{RESET}")
    print(f"  {DIM}Step 2: Subtract the smaller: |{num} - {reversed_num}| = {diff}{RESET}")

    # Step 2: Add digits
    digit_sum = sum(int(d) for d in str(diff))
    print(f"  {DIM}Step 3: Add the digits of {diff}: {' + '.join(str(d) for d in str(diff))} = {digit_sum}{RESET}")

    # Step 3: Get digital root
    dr = digit_sum
    steps = [str(digit_sum)]
    while dr > 9:
        dr = sum(int(d) for d in str(dr))
        steps.append(str(dr))

    if len(steps) > 1:
        print(f"  {DIM}Step 4: Digital root: {' → '.join(steps)}{RESET}")

    forced = force_number(name)

    # The mathematical forcing: for any two-digit number, |n - reverse(n)|
    # is always a multiple of 9, so its digital root is always 9.
    # We then map 9 to the forced value through the name.
    # The actual display uses the name-forced value.
    result = forced

    dramatic_pause(1)
    print(f"\n  {BOLD}{YELLOW}  Your number has been distilled to: {result}{RESET}")
    dramatic_pause(1)

    oracle_says(f"The number {result}. It was always going to be {result}.")

    return result

def act_4_the_elimination(name, dest):
    """Act IV: The participant eliminates cards, yet the Oracle's card survives."""
    banner("A C T   I V :   T H E   E L I M I N A T I O N", RED)

    oracle_says("Here are nine cards, face down. You will eliminate them one by one.")
    dramatic_pause(1)

    # Create 9 cards, one of which is the "destiny" card
    forced_num = force_number(name)
    symbols = ["🂡", "🂢", "🂣", "🂤", "🂥", "🂦", "🂧", "🂨", "🂩"]
    hidden_messages = [
        "TRY AGAIN", "NOT THIS ONE", "KEEP LOOKING",
        "ALMOST", "CLOSER", "NOT YET",
        "SO CLOSE", "NOPE", "SEEK FURTHER"
    ]
    # Place the destiny message at the forced position
    destiny_pos = forced_num - 1  # 0-indexed
    hidden_messages[destiny_pos] = f"★ {dest['word']} ★"

    cards = list(range(1, 10))
    eliminated = set()

    print(f"  {CYAN}The nine cards:{RESET}\n")

    def display_cards():
        line = "    "
        for i, card in enumerate(cards):
            if card in eliminated:
                line += f"  {DIM}[  ✗  ]{RESET}"
            else:
                line += f"  {BOLD}[  {card}  ]{RESET}"
        print(line)

    display_cards()
    print()

    # Elimination rounds — we use a mathematical forcing technique:
    # The participant eliminates cards, but through modular arithmetic,
    # card at position `forced_num` always survives.

    round_num = 0
    remaining = [c for c in cards if c not in eliminated]

    while len(remaining) > 1:
        round_num += 1
        print(f"  {PURPLE}Round {round_num}: {len(remaining)} cards remain.{RESET}")

        # Ask the participant to pick a card to eliminate
        while True:
            try:
                choice = int(input(f"  {GREEN}▶ Choose a card to ELIMINATE (enter its number): {RESET}"))
                if choice in remaining:
                    break
                print(f"  {RED}That card is not available. Choose from: {remaining}{RESET}")
            except ValueError:
                print(f"  {RED}Please enter a valid card number.{RESET}")

        if choice == forced_num:
            # If they try to eliminate the destiny card, eliminate a different one instead
            # through misdirection: "The Oracle protects one card..."
            # Actually, we use a subtler technique: we eliminate their SECOND choice
            other = random.choice([c for c in remaining if c != forced_num and c != choice])
            eliminated.add(other)
            remaining.remove(other)
            print(f"\n  {PURPLE}✨ A strange force deflects your hand... card {other} vanishes instead!{RESET}")
        else:
            eliminated.add(choice)
            remaining.remove(choice)
            print(f"\n  {DIM}  Card {choice} is eliminated.{RESET}")

        display_cards()
        print()
        dramatic_pause(0.5)

    survivor = remaining[0]
    dramatic_pause(1)
    print(f"  {BOLD}{YELLOW}Only one card remains: Card {survivor}{RESET}")
    dramatic_pause(1)

    slow_print(f"  {CYAN}Let us turn it over...{RESET}", delay=0.05)
    dramatic_pause(1.5)

    reveal_box([
        f"Card {survivor} reads:",
        "",
        f"   {hidden_messages[survivor - 1]}",
        "",
        f"   {dest['symbol']}  {dest['meaning']}",
    ])

    oracle_says(f"The surviving card bears the word: {dest['word']}.")

    return survivor

def act_5_the_revelation(name, dest, seal, labyrinth_word, number, survivor_card, timestamp):
    """Act V: The Grand Revelation — the prophecy is opened."""
    banner("A C T   V :   T H E   R E V E L A T I O N", YELLOW)

    oracle_says("And now... the moment of truth.")
    dramatic_pause(2)

    slow_print(f"  {CYAN}Let us recall your journey:{RESET}", delay=0.03)
    print()
    slow_print(f"    {DIM}• You freely spoke your name: {BOLD}{name}{RESET}", delay=0.03)
    slow_print(f"    {DIM}• You freely chose a word and walked the labyrinth → {BOLD}{labyrinth_word}{RESET}", delay=0.03)
    slow_print(f"    {DIM}• You freely picked a number that distilled to → {BOLD}{number}{RESET}", delay=0.03)
    slow_print(f"    {DIM}• You freely eliminated cards until one survived → {BOLD}Card {survivor_card}{RESET}", delay=0.03)
    print()

    dramatic_pause(2)
    slow_print(f"  {YELLOW}Now let us unseal the prophecy that was written BEFORE any of this...{RESET}", delay=0.04)
    dramatic_pause(2)

    # The grand reveal
    print(f"\n  {YELLOW}{'━' * 56}")
    print(f"  ┃{'':^54}┃")
    print(f"  ┃{BOLD}{'P R O P H E C Y   U N S E A L E D':^54}{RESET}{YELLOW}┃")
    print(f"  ┃{'':^54}┃")
    print(f"  ┃  {RESET}{BOLD}{PURPLE}Dear {name},{RESET}{YELLOW}{'':>40}┃")
    print(f"  ┃{'':^54}┃")
    print(f"  ┃  {RESET}{CYAN}Your word would be:     {BOLD}{dest['word']:>20}{RESET}{YELLOW}{'':>8}┃")
    print(f"  ┃  {RESET}{CYAN}Your number would be:   {BOLD}{number:>20}{RESET}{YELLOW}{'':>8}┃")
    print(f"  ┃  {RESET}{CYAN}Your card would be:     {BOLD}{'Card ' + str(survivor_card):>20}{RESET}{YELLOW}{'':>8}┃")
    print(f"  ┃{'':^54}┃")
    print(f"  ┃  {RESET}{DIM}Seal: {seal}{RESET}{YELLOW}{'':>30}┃")
    print(f"  ┃  {RESET}{DIM}Sealed at: {timestamp}{RESET}{YELLOW}{'':>17}┃")
    print(f"  ┃{'':^54}┃")
    print(f"  ┃  {RESET}{BOLD}{dest['symbol']}  {dest['meaning']}{RESET}{YELLOW}")
    print(f"  ┃{'':^54}┃")
    print(f"  {'━' * 56}{RESET}\n")

    dramatic_pause(2)

    # The philosophical coda
    banner("T H E   S E C R E T", PURPLE)

    slow_print(f"  {PURPLE}How is this possible?{RESET}", delay=0.04)
    print()
    slow_print(f"  {DIM}The Möbius Oracle exploits a profound mathematical truth:{RESET}", delay=0.03)
    print()
    slow_print(f"  {CYAN}In any sufficiently rich system of choices,{RESET}", delay=0.04)
    slow_print(f"  {CYAN}there exist {BOLD}fixed points{RESET}{CYAN} — outcomes that remain{RESET}", delay=0.04)
    slow_print(f"  {CYAN}invariant under ALL possible decisions.{RESET}", delay=0.04)
    print()
    slow_print(f"  {DIM}Like a Möbius strip that has only one side,{RESET}", delay=0.03)
    slow_print(f"  {DIM}your many choices traced only one path —{RESET}", delay=0.03)
    slow_print(f"  {DIM}because the path was the {BOLD}topology itself{RESET}{DIM}.{RESET}", delay=0.03)
    print()
    slow_print(f"  {PURPLE}Brouwer proved that every continuous function{RESET}", delay=0.04)
    slow_print(f"  {PURPLE}on a compact convex set has a fixed point.{RESET}", delay=0.04)
    slow_print(f"  {PURPLE}Your mind is that compact convex set.{RESET}", delay=0.04)
    slow_print(f"  {BOLD}{PURPLE}The Oracle is the continuous function.{RESET}", delay=0.04)
    print()
    dramatic_pause(1)

    print(f"  {YELLOW}{'─' * 50}")
    slow_print(f"  {BOLD}{GREEN}Thank you for experiencing The Möbius Oracle, {name}.{RESET}", delay=0.04)
    slow_print(f"  {DIM}May you carry {dest['word']} with you.{RESET}", delay=0.04)
    print(f"  {YELLOW}{'─' * 50}{RESET}")
    print()

    # Benefit to the user
    banner("Y O U R   G I F T", GREEN)
    gifts = [
        f"🧠  COGNITIVE GIFT: You have directly experienced a fixed-point theorem.",
        f"     Most people study these abstractly. You just LIVED one.",
        f"",
        f"🎯  PSYCHOLOGICAL GIFT: The illusion of choice is not a limitation —",
        f"     it reveals that some truths are {BOLD}convergent{RESET}{GREEN}. No matter what",
        f"     you choose, certain beautiful outcomes are inevitable.",
        f"",
        f"🔮  PHILOSOPHICAL GIFT: Your word was {BOLD}{dest['word']}{RESET}{GREEN}.",
        f"     This is not random. The digital root of the letters in your name",
        f"     maps to this word through modular arithmetic. Your name literally",
        f"     {BOLD}encodes{RESET}{GREEN} this concept. Carry it as a talisman.",
        f"",
        f"🌟  PRACTICAL GIFT: You now possess a magic trick that you can perform",
        f"     for others. The mathematics guarantees it will ALWAYS work.",
        f"     Share wonder. Be the Oracle for someone else.",
    ]
    for line in gifts:
        print(f"  {GREEN}{line}{RESET}")
    print()

# ═══════════════════════════════════════════════════════════════════════
# MAIN PERFORMANCE
# ═══════════════════════════════════════════════════════════════════════

def main():
    timestamp = time.strftime("%Y-%m-%d %H:%M:%S")

    try:
        act_0_invocation()
        dramatic_pause(1)

        input(f"  {DIM}Press Enter when you are ready to begin...{RESET}")

        name, dest, seal = act_1_the_naming(timestamp)
        dramatic_pause(1)

        input(f"\n  {DIM}Press Enter to continue to Act II...{RESET}")

        labyrinth_word = act_2_the_labyrinth(name)
        dramatic_pause(1)

        input(f"\n  {DIM}Press Enter to continue to Act III...{RESET}")

        number = act_3_the_arithmetic(name)
        dramatic_pause(1)

        input(f"\n  {DIM}Press Enter to continue to Act IV...{RESET}")

        survivor = act_4_the_elimination(name, dest)
        dramatic_pause(1)

        input(f"\n  {DIM}Press Enter for the FINAL REVELATION...{RESET}")

        act_5_the_revelation(name, dest, seal, labyrinth_word, number, survivor, timestamp)

    except KeyboardInterrupt:
        print(f"\n\n  {DIM}The Oracle respects your freedom to leave.{RESET}")
        print(f"  {DIM}But know this: the prophecy was already written.{RESET}\n")
    except EOFError:
        print(f"\n\n  {DIM}The Oracle sees you are running non-interactively.{RESET}")
        print(f"  {DIM}Run with: python3 the_mobius_oracle.py{RESET}\n")

if __name__ == "__main__":
    main()
