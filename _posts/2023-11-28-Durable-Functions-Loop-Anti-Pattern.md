---
title: Durable Functions - Loop Anti Pattern
date: 2023-11-28
categories: [Azure, Azure Functions]
tags: [azure, azure functions, serverless]     # TAG names should always be lowercase
---

Ever felt like your durable functions are moving at a snails pace? Well you are not alone! During my time at Microsoft I met a lot of people who faced grave performance issues with Durable Functions and today I would like to talk about on of the most common issues that I call the **Loop Anti Pattern.**. This pattern emerges when you await code inside a loop forcing the Durable Function to wait for each itteration of the loop rather than running all executions in parallel. 

I would like start by saying I understand that people get this wrong, and I partly blame Microsoft! The default template have led a lot of people wrong when it comes to this code with its example outputs.add(await..) as people now tend to take this example and use it in loops like this. 

```csharp
[FunctionName("Function1")]
public static async Task<List<string>> RunOrchestrator(
    [OrchestrationTrigger] IDurableOrchestrationContext context)
{
    var outputs = new List<string>();
    
    // region GenerateFakeInvoices - Generate some fake invoices to test.
   
    for (int i = 0; i < 1000;i++)
    {
				//Forces Durable Functions to write state each time you execute your function!
        outputs.Add(await context.CallActivityAsync<string>(nameof(CalculateInvoice), invoices[i]));
    }
    
    return outputs;
}
```

The problem that arises is that the await triggers a sort of “Quick save” for the Durable Functions were it goes and saves it state so for every single loop it saves state and waits effectively running the code sequentially, and in most cases this is not the expected result. 

A solution to this problem is to run the code as a collection of Tasks and await them once to allow them to run in parallel and not bother us until they are completed as seen in this example. 

```csharp
[FunctionName("Function1")]
public static async Task<List<string>> RunOrchestrator([OrchestrationTrigger] IDurableOrchestrationContext context)
{
    var outputs = new List<string>();
    
    // region GenerateFakeInvoices - Generate some fake invoices to test.

    var tasks = new List<Task<string>>();

    for (int i = 0; i < 1000;i++)
    {
        tasks.Add(context.CallActivityAsync<string>(nameof(CalculateInvoice), invoices[i]));
    }

    await Task.WhenAll(tasks);

    foreach (var task in tasks) 
    {
        outputs.Add(task.Result);
    }

    return outputs;
}
```

The difference is staggering, running in the Azure Functions emulator I gave up after 8 minutes of runtime and the below example is done in under 2 minutes.
