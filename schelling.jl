using Agents, InteractiveDynamics, GLMakie
using Statistics: mean

@agent struct Schelling(GridAgent{2}) 
    isHappy::Bool = false 
    group::Int 
end

properties = Dict(:min_to_be_happy => 3)
space = GridSpace((20, 20), periodic = false)

function schelling_step!(agent, model)

    minhappy = model.min_to_be_happy
    count_neighbors_same_group = 0

    for neighbor in nearby_agents(agent, model)
        if agent.group == neighbor.group
            count_neighbors_same_group += 1
        end
    end

    if count_neighbors_same_group ≥ minhappy
        agent.isHappy = true
    else
        agent.isHappy = false
        move_agent_single!(agent, model)
    end
    return
end

model = StandardABM(
    Schelling,
    space;
    agent_step! = schelling_step!, properties
)

for n in 1:300
    add_agent_single!(model; group = n < 300 / 2 ? 1 : 2)
end


xpos(agent) = agent.pos[1]
adata = [(:isHappy, sum), (xpos, mean)]
adf, mdf = run!(model, 5; adata)
adf