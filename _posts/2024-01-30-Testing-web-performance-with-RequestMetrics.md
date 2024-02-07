---
title: Testing web performance with RequestMetrics
date: 2024-01-30
categories: [Performance Monitoring]
tags: [monitoring, performance, review]     # TAG names should always be lowercase
---

This weekend I decided to try the performance monitoring tool [Request Metrics](https://requestmetrics.com) a tool I never knew I needed! I have used tools like Google analytics for website performance; though good for business analytics it lacked the raw performance metrics I expected.

## Why RequestMetrics?
[Request Metrics](https://requestmetrics.com) founder Todd Gardner, is a friend of mine that I have got to know at conferences around the world, he is an excellent web developer and JavaScript aficionado and I have followed the journey of his earlier project TrackJS closely. Hearing about Request Metrics as a "simpler and easier" web performance tool I decided to piggy back on his knowledge to learn more. 

## Setup and first Impressions
Setting up RequestMetrics was quite easy, I enrolled and got to choose between a JavaScript snippet, NPM package, Script Tag, [Google Tag Manager](https://support.google.com/tagmanager/answer/6102821?hl=en) or browser extension (More on why this feature is amazing soon!). I started with a JavaScript snippet and the most complex part of that was figuring out how to add a custom header definition for Jekyll, as I, for some reason, often confuse its name with Jenkins the CI/CD tool. 

The RequestMetrics dashboard presented me with terms such as LCP (Largest Contentful Paint), CLS (Cumulative Layout Shift), INP (Interaction to Next Paint), TTFB (Time To First Byte), FCP (First Contentful Paint), and FID (First Input Delay). These abbreviations are key performance indicators in web development and are essential for understanding a website's user experience, but I HAD VERY LITTLE KNOWLEDGE of them despite being more or less industry standard! I'm glad for the direct approach, giving me the chance to properly learn these metrics. 

LCP (Largest Contentful Paint) measures the time it takes for the largest content element visible in the viewport to become fully rendered. This is crucial for understanding the loading experience of the site. 

CLS (Cumulative Layout Shift) quantifies how much unexpected layout shift occurs during the lifespan of the page. A high CLS indicates a less stable and potentially frustrating user experience.

INP (Interaction to Next Paint) measures the responsiveness of a page by quantifying the time between a user's interaction (like a click or a tap) and the visual response or feedback from the page.

TTFB (Time To First Byte) measures the time from the user or client making an HTTP request to the first byte of the page being received by the browser. This metric is critical in assessing the speed of a web server or network.

FCP (First Contentful Paint) measures the time from when the page starts loading to when any part of the page's content is rendered on the screen. It's an important indicator of perceived load speed.

FID (First Input Delay) measures the time from when a user first interacts with your site (i.e., when they click a link, tap on a button) to the time when the browser is actually able to respond to that interaction. This metric is key in understanding the interactivity of a page.

## Insights gained
So the first thing that I learned is that I have little to no readers! The second is that GitHub pages + Jekyll is a pretty decent stack in terms of performance. Simply said it was a bad idea to test this with a small personal blog with few readers with a well known standardized tech stack. 

As luck would have it just a few days later I was working with a low-code portal applications where I had no performance data, a perfect time to test this tool more in-depth! I noticed that this tool did not allow me to setup custom scripts tags so here the Edge/Chrome plugin were perfect! Without installing or changing anything I could get insights into the performance of the website and after about half an hour of testing I had a very good idea of the applications least performant features and what parts of these sites that needed improvement. I fully expected to never use the browser extension, but the ability to test any website when ever I need actually made this one of my favorite features. 

I will be spending the time writing a plugin for this portal as having these metrics as part of UAT will be magical! In the future when a user says "the website is slow" we will know exactly how slow and what parts of the site even. Given that I can get that type of data for multiple production system for $49 I think the price point is quite fair, even if I will stick with the free tier for my blog, at least until I have more readers :laughing:

## Conclusion

In short, RequestMetrics is surprisingly useful. It's a tool I stumbled upon without realizing how much I needed it. Initially, testing it on my small blog didn't showcase its full capabilities, but applying it in a more complex environment revealed its worth. The browser extension, in particular, turned out to be more helpful than anticipated, offering insights with minimal fuss.

I plan to keep RequestMetrics in my toolbox as it simplifies the complex world of web performance metrics, making it easier to pinpoint issues in the ever varying world wide web. 