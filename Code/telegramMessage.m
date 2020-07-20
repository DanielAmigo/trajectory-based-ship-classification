%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Desarrollado por | Developed by:                     %
% University Carlos III of Madrid PhD Researchers      %
% Daniel Amigo Herrero    mailto: damigo@inf.uc3m.es   %
% David Sanchez Pedroche  mailto: davsanch@inf.uc3m.es %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function telegramMessage(message)
% Para crear un bot de telegram
% https://www.forsomedefinition.com/automation/creating-telegram-bot-notifications/
import matlab.net.*
import matlab.net.http.*

modeSend   = "noweb";% web noweb
outputMode = "No"; % Dani GIAA

if strcmp(outputMode, "Dani") % DANI token and chat_id
    token = '-';
    chat_id = '-';
elseif strcmp(outputMode, "GIAA") % MATLAB GIAA token and chat_id
    token = '';
    chat_id = '';
else
    return
end

% convert MATLAB string to url query string
sendstr = urlencode(message);   % Generamos el mensaje
sendstr = ['https://api.telegram.org/bot',token,'/sendMessage?chat_id=',chat_id,'&text=',sendstr];

try
    if strcmp(modeSend, "noweb") % Env�a el mensaje sin abrir una web
        r = RequestMessage;
        uri = URI(sendstr);
        options = matlab.net.http.HTTPOptions('ConnectTimeout',4);
        resp = send(r, uri);
        status = resp.StatusCode;
    elseif strcmp(modeSend, "noweb") % Env�a el mensaje abriendo y cerrando una web
        [stat,h] = web(sendstr); % Enviamos el mensaje usando la API
        pause(2);                % Un poco de tiempo para que termine a tiempo
        close(h);                % Cerramos el navegador web
    end
catch
    disp("Error al intentar el mensaje de telegram. " + message);
end

end