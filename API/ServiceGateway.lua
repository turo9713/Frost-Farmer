local ServiceGateway = {}

function ServiceGateway.request(service, payload)
    return { service = service, payload = payload }
end

return ServiceGateway
