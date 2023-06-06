public class ChatGPT {
//
// Author: Nilan Fernando
// Flow Action to create a request to ChatGPT
//
    @InvocableMethod(label='Call ChatGPT' description='OpenAI Chat GPT' category='ChatGPT')
    public static List<String> callChatGPT(List<Request> requests) {
 
            List<String> results = new List<String>();

        string status;
        String authToken;
        string txtResponse;
        messages[] msgs = new List<messages>();
        
        GptRequest gpt = new GptRequest();
            gpt.model='gpt-3.5-turbo';
            gpt.temperature=0.7;
            gpt.top_p=1;
            gpt.frequency_penalty=0;
            gpt.presence_penalty=0;
            gpt.max_tokens=2000;

        Http htp = new Http();
        HttpResponse response;
        HttpRequest req = new HttpRequest();
            req.setEndpoint('https://api.openai.com/v1/chat/completions');
 //           req.setEndpoint('callout:chatgpt/v1/chat/completion');
            req.setMethod('POST');
            req.setHeader('Content-Type', 'application/json');
            req.setTimeout(12000);


            for (Request request: requests) {
               String responseBody;

               if (request.temp > 0 && request.temp <= 2){
                gpt.temperature = request.temp;
               }

               if ((request.apikey!=null) && (String.isNotBlank(request.apikey))) {
                //set the API key
                authToken  = 'Bearer '+ request.apikey;
                }

                if (request.tokens!=null) {
                    gpt.max_tokens = request.tokens;
                }
                
               messages msg1 = new messages();
               if (String.isNotBlank(request.content1)) {
                msg1.content = request.content1;
                   if ((String.isNotBlank(request.role1))){
                    msg1.role = request.role1;
                     }
                    else
                    { 
                       msg1.role='user';
                    }
                msgs.add(msg1);
                }
               
                if ((String.isNotBlank(request.role2)) && (String.isNotBlank(request.content2))) {
                    messages msg2 = new messages();
                        msg2.role = request.role2;
                        msg2.content = request.content2;
                    msgs.add(msg2);
                }
                
                if (msgs != null) {
                    gpt.messages = msgs;
                }
               String requestBody = JSON.serialize(gpt);
               req.setBody(requestBody);
               req.setHeader('Authorization', authToken);
               try {
                    response = htp.send(req);
                    if (response.getStatusCode()== 200) {
                        responseBody = response.getBody();
                        Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(responseBody);
                        if (responseMap != null) {
                            List<Object> choices = (List<Object>) responseMap.get('choices');
                            if (choices != null )
                            {
                                for (Object choice : choices) {
                                        Map<String, Object> curChoice = (Map<String, Object>) choice;
                                        Map<String, Object> message = (Map<String, Object>) curChoice.get('message');
                                        txtResponse = (String) message.get('content');                  
                                }
                                results.add(txtResponse);
                             }
                            else {
                                 txtResponse = responseBody + '   ' + response.getStatus();
                                 results.add(txtResponse);                 
                                }     
                        }

                     }

                 }
                catch (Exception e) {
                    status = e + '';
                    results.add(status);
                }             
            }
        return results;
     }

    public class GptRequest {
        public string model;
        public Decimal top_p = 1;   
        public Decimal temperature;         //0-1  Controls diversity via nucleus sampling. 0.5 means half of all likely hood weighted options are considered.
        public Decimal frequency_penalty = 0;    //-2.0 - 0 Positive values penalize new tokens based on their existing frequency in the text so far, decreasing the model’s likelihood to repeat the same line verbatim.
        public Decimal presence_penalty = 0;     //-2.0 - 0 Positive values penalize new tokens based on whether they appear in the text so far, increasing the model’s likelihood to talk about new topics.
        public integer max_tokens;  
        public messages[] messages;
    }

    public class messages {
        public string role;
        public string content;
    }


    public class Request {
        @InvocableVariable(label ='content1' required=true) public String content1;
        @InvocableVariable(label ='role1 (system/user/assistant) defaults to user' required=false) public String role1;
        @InvocableVariable(label ='content2  optional') public String content2;
        @InvocableVariable(label ='role2 (system/user/assistant) optional' ) public String role2;
        @InvocableVariable(label ='API Key' required=true) public String apikey;
        @InvocableVariable(label ='temperature (optional) a value between 0 - 2.0' required=false) public Decimal temp;
        @InvocableVariable(label ='max tokens (optional) default is 200 tokens' required=false) public integer tokens;

    } 
}