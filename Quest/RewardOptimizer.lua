local RewardOptimizer = {}

function RewardOptimizer:BestReward(rewards)
    return rewards and rewards[1]
end

return RewardOptimizer