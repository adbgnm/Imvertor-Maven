package nl.imvertor.common.file;

import java.io.BufferedReader;
import java.io.File;
import java.io.IOException;
import java.io.InputStreamReader;
import java.net.URI;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.Iterator;
import java.util.List;
import java.util.Map;
import java.util.Map.Entry;

import org.apache.http.HttpEntity;
import org.apache.http.HttpResponse;
import org.apache.http.NameValuePair;
import org.apache.http.client.HttpClient;
import org.apache.http.client.entity.UrlEncodedFormEntity;
import org.apache.http.client.methods.CloseableHttpResponse;
import org.apache.http.client.methods.HttpPost;
import org.apache.http.client.methods.HttpUriRequest;
import org.apache.http.client.methods.RequestBuilder;
import org.apache.http.entity.ContentType;
import org.apache.http.entity.StringEntity;
import org.apache.http.entity.mime.MultipartEntityBuilder;
import org.apache.http.impl.client.CloseableHttpClient;
import org.apache.http.impl.client.HttpClients;
import org.apache.http.message.BasicNameValuePair;

public class HttpFile extends AnyFile {

	private static final long serialVersionUID = 3111631389431655771L;
	
	public final static int METHOD_POST_FILE = 0;
	public final static int METHOD_POST_CONTENT = 1;
	
	private int status = -1;

	public HttpFile(File file) {
		super(file);
	}
	public HttpFile(String file) {
		super(file);
	}

	/**
     * Get info from URL.
     *      
     * @return Body of the request
     * @throws Exception 
     */
	public String get(URI url, Map<String, String> headerMap) throws Exception {
		
		// create a request builder
		RequestBuilder builder = RequestBuilder.get();
		builder.setUri(url);

		// add headers
		if (headerMap != null) {
			Iterator<Entry<String,String>> it = headerMap.entrySet().iterator();
			while (it.hasNext()) {
				Entry<String,String> e = it.next();
				builder.addHeader(e.getKey().toString(), e.getValue().toString());
			}
		}
		
		// build and execute the request
		HttpClient client = HttpClients.custom().build();
		HttpUriRequest request = builder.build();
		HttpResponse response = client.execute(request);

		// get the status of the response
		this.status = response.getStatusLine().getStatusCode();

		// get the contents of the response
		return getResponseBody(response);
	
	}
	
	// http://www.baeldung.com/httpclient-post-http-request
	
	/**
	 * 
	 * 
	 * @param url
	 * @param parms
	 * @param payload
	 * @return
	 * @throws Exception
	 */
	public String post(int method, URI url, Map<String, String> headerMap, HashMap<String, String> parms, String payload) throws Exception {
		
		CloseableHttpClient client = HttpClients.createDefault();
	    HttpPost httpPost = new HttpPost(url);
	 
	 	// add headers
	    if (headerMap != null) {
	    	Iterator<Entry<String,String>> headerIterator = headerMap.entrySet().iterator();
	 		while (headerIterator.hasNext()) {
	 			Entry<String,String> e = headerIterator.next();
	 			httpPost.addHeader(e.getKey().toString(), e.getValue().toString());
	 		}
	    }
	    
	    // add parms
 		if (parms != null) {
 			Iterator<Entry<String,String>> paramIterator = parms.entrySet().iterator();
 			List<NameValuePair> params = new ArrayList<NameValuePair>();
 		 	while (paramIterator.hasNext()) {
 		 		Entry<String,String> e = paramIterator.next();
 	 			params.add(new BasicNameValuePair(e.getKey().toString(), e.getValue().toString()));
 	 		}
 		    httpPost.setEntity(new UrlEncodedFormEntity(params));
	    }
 		
 		// check which type of post is intended
 		if (method == METHOD_POST_CONTENT && payload != null) {
	 		StringEntity entity = new StringEntity(payload);
		    httpPost.setEntity(entity);
 		} else if (method == METHOD_POST_FILE && payload != null) {
 			File file = new File(payload);
 			MultipartEntityBuilder builder = MultipartEntityBuilder.create();
 		    builder.addBinaryBody("file",file,
 		      ContentType.APPLICATION_OCTET_STREAM, file.getName());
 		    HttpEntity multipart = builder.build();
 		    httpPost.setEntity(multipart);
 		} 
 	    
	    // execute the post request
	    CloseableHttpResponse response = client.execute(httpPost);
	    
	    // get the status of the response
	 	this.status = response.getStatusLine().getStatusCode();
	 	
	 	// and get the contents of the response
	 	String body = getResponseBody(response);
	
	 	// close the client
	    client.close();

	    return body;
	}
	
	public int getStatus() {
		return status;
	}
	public String getResponseBody(HttpResponse response) throws Exception, IOException {
		BufferedReader in = new BufferedReader(new InputStreamReader(response.getEntity().getContent()));
		String inputLine;
		StringBuffer responseText = new StringBuffer();
		while ((inputLine = in.readLine()) != null)
			responseText.append(inputLine);
		in.close();
		return responseText.toString();
	}

}