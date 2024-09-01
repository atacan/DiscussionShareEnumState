# Deriving shared state to a child reducer with enum state.

Imagine an app like the Mail app on macOS.  
When you select one mail, it will show you the details of the selected mail item.  
When you select multiple emails, it will themn show like stacked papers. 

## Initial Approach

Having a list of items on the left sidebar and creating views on the right-hand side conditionally on whether one item or multiple items are selected,  
I structured the reducer with a parent reducer having an array of items and a child reducer that has an enum state with single or multi, which has the associated values of the single item view reducer and multiple item view reducer states. 

Here is a toy project that has the reducers and the views, but of course, it does not reflect the edits that are made in the single item view to the parent's array.

https://github.com/atacan/DiscussionShareEnumState/blob/main/DiscussionShareEnumState/ContentView.swift

I thought about using the `Destination` approach but I couldn't figure out scoping the store to item views' stores.

## Question

As this is a macOS app, and both views are visible at the same time, and I have this multi-selection view as well,  
I don't think I would be able to use the navigation APIs of Swift, such as NavigationLink, etc.  

Would you have a suggestion on how to implement this?