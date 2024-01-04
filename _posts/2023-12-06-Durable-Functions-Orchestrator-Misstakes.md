---
title: Durable Functions - Orchestrator Misstakes and Misshaps
date: 2023-11-28
categories: [Azure, Azure Functions]
tags: [azure, azure functions, serverless] 
---

Durable functions, i.e serverless functions that can work with state and orchestration have been of great use to me over the years but I have also met a lot of people who were frustrated with them and had issues with their performance. In this post we will look at a common scenario for many users where the orchestrator function starts rather fast but then grinds to a halt! In this example it runs at about 850 milliseconds at first but then takes up to 35 seconds to complete. This bug can be hard to track as the single function is runs compleates in milliseconds, some customers that I have worked with even reported their orchestrator grinded to a halt finishing days later, so what is going on?

In total this simple result took 15 minutes to calculate, 

```json
{
    "name": "Function1",
    "instanceId": "b822dd8a8e4f469986dfca25bf2f735b",
    "runtimeStatus": "Completed",
    "input": null,
    "customStatus": null,
    "output": [
       ...50 omitted lines of json data
    ],
    "createdTime": "2023-12-06T06:06:33Z",
    "lastUpdatedTime": "2023-12-06T06:21:36Z"
}

```

```csharp
        [FunctionName("Function1")]
        public static async Task<List<string>> RunOrchestrator(
            [OrchestrationTrigger] IDurableOrchestrationContext context)
        {
            var outputs = new List<string>();
            
            #region GenerateFakeInvoices

            for (int i = 0; i < 50;i++)
            {
                outputs.Add(await context.CallActivityAsync<string>(nameof(CalculateInvoice), invoices[i]));
                HttpClient client = new HttpClient();

                var test = client.GetAsync("https://httpbin.org/get").Result.Content;
            }
            
            return outputs;
        }

```

The most likely error with the code is that **we are doing network calls inside a durable function orchestrator** witch is inself a constraint from the durable task framework that Durable Functions runs on and this can cause multiple issues on its own. Normally we consume APIs from functions triggered by the orchestrator but starting with Durable Functions 2.0, orchestrations can consume HTTP APIs by using the orchestration context.

```csharp
 public static class Function1
 {
     [FunctionName("Function1")]
     public static async Task<List<string>> RunOrchestrator(
         [OrchestrationTrigger] IDurableOrchestrationContext context)
     {
         var outputs = new List<string>();
         
         #region GenerateFakeInvoices
       
         for (int i = 0; i < 50;i++)
         {
             outputs.Add(await context.CallActivityAsync<string>(nameof(CalculateInvoice), invoices[i]));             

             var httpReq = new DurableHttpRequest(HttpMethod.Get,new Uri("https://httpbin.org/get"));
             var test = await context.CallHttpAsync(httpReq);
         }
         
         return outputs;
     }
```

This gets our request time down to two minutes, better and with the fan out pattern that I wrote about in [Durable Functions - Loop Anti Pattern]({% post_url 2023-11-28-Durable-Functions-Loop-Anti-Pattern %}) it would of course run even faster.