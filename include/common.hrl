-define(INFO(Message,Args), lager:log(info, self(), Message, Args)).

-define(ERR(Message,Args), lager:log(error, self(), Message, Args)).