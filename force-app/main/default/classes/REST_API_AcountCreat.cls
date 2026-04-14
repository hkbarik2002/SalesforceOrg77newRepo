@RestResource(urlMApping = '/CreatAccountRestApi')
global class REST_API_AcountCreat {
    @httpPost
    global Static void creatApiAccount(){
        RestRequest req = RestContext.Request;
        System.debug('req>>>'+req);
        String s1 = req.requestBody.toString();
        If(string.isNotBlank(s1)){
            Wrapper er = (Wrapper)Json.deserialize(s1,Wrapper.class);
            System.debug('er>>>'+er);
            Account acc = new Account(Name = er.name,Phone = er.phone,Type = er.actype);
            try{
                Insert acc;
                String responseBody = '{"Status":"Sucess","Msg":"Account Creat Sucessfully"}';
                RestContext.response.addHeader('Content-Type','application/json');
                RestContext.response.responseBody = Blob.valueOf(responseBody);
            }catch(Exception ex){
                System.debug('Line Number: '+ex.getLineNumber());
                System.debug('Ex Massage: '+ex.getMessage());
            }
        }
    }
    public class Wrapper{
        public string name;
        public String phone;
        public string actype;
    }
}