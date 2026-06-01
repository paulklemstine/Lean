def compute_asymmetry_gap(game, max_rounds=100, num_trials=100):
    ms = safe_strategy(game)
    adv_es = adversarial_eternity(game)
    adv_survival = simulate_survival(game, ms, adv_es, max_rounds)
    random_survivals = [simulate_survival(game, ms, random_eternity(game.num_eternity_moves), max_rounds) for _ in range(num_trials)]
    return abs(adv_survival - sum(random_survivals)/len(random_survivals))