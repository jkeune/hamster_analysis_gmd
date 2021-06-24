aggreg_x_mean = function(x,ne,...){xm = tapply(x, rep(1:(length(x)/ne), each = ne), mean, ...);return(xm)}
